#include "common/draw/types.h"
#include <cassert>
#include <chrono>
#include <goopax>
#include <goopax_extra/param.hpp>
#include <goopax_extra/random.hpp>
#include <random>

using namespace Eigen;
using namespace std::chrono;
using namespace goopax;
using namespace std;

PARAMOPT<size_t> NK("nk", 2048); // Matrix sizes. Can be specified as command line arguments,
PARAMOPT<size_t> NL("nl", 2048); // e.g., --nk=128 --nl=256 --nm=384
PARAMOPT<size_t> NM("nm", 2048);

template<typename ab_float_type, typename c_float_type>
struct matmul
{
    using gpu_ab_float_type = typename make_gpu<ab_float_type>::type;
    using gpu_c_float_type = typename make_gpu<c_float_type>::type;
    goopax_device device;

    const unsigned int Nk;
    const unsigned int Nl;
    const unsigned int Nm;

    buffer<ab_float_type> A;
    buffer<ab_float_type> B;
    buffer<c_float_type> C;

    std::random_device rd;
    WELL512_data rnd;
    kernel<void(buffer<ab_float_type>& a)> fill_random;
    VectorX<double> test_vector;

    kernel<void()> kernel_simple;
    kernel<void()> kernel_tensor;

    matmul(goopax_device device0, unsigned int Nk0, unsigned int Nl0, unsigned int Nm0)
        : device(device0)
        , Nk(Nk0)
        , Nl(Nl0)
        , Nm(Nm0)
        , rnd(device, device.default_global_size_max(), rd())
    {
        A.assign(device, Nk * Nl);
        B.assign(device, Nl * Nm);
        C.assign(device, Nk * Nm);

        fill_random.assign(device, [this](resource<ab_float_type>& a) {
            WELL512_lib rndlib(rnd);

            for_each_global(a.begin(), a.end(), [&](gpu_ab_float_type& v) {
                v = static_cast<gpu_ab_float_type>(rndlib.gaussian_distribution());
            });
        });

        fill_random(A);
        fill_random(B);

        {
            std::default_random_engine generator;
            std::normal_distribution<double> distribution;
            test_vector = VectorX<double>(Nm);
            for (double& e : test_vector)
            {
                e = distribution(generator);
            }
        }

        kernel_simple.assign(device, [this]() {
            const_resource A(this->A);
            const_resource B(this->B);
            resource C(this->C);

            gpu_for_group(0, Nk, [&](gpu_uint k) {
                gpu_for_local(0, Nm, [&](gpu_uint m) {
                    gpu_c_float_type sum = static_cast<c_float_type>(0);
                    gpu_for(0, Nl, [&](gpu_uint l) {
                        sum += A[k * Nl + l] * static_cast<gpu_c_float_type>(B[l * Nm + m]);
                    });
                    C[k * Nm + m] = sum;
                });
            });
        });

        // sub-matrix sizes used in tensor cores
        static constexpr uint bk = sizeof(ab_float_type) == 8 ? 8 : 16;
        static constexpr uint bl = sizeof(ab_float_type) == 8 ? 4 : 16;
        static constexpr uint bm = sizeof(ab_float_type) == 8 ? 8 : 16;

        if (device.support_warp_matrix<ab_float_type, c_float_type>(bk, bm, bl))
        {
            kernel_tensor.assign(device, [this]() {
                const_resource A(this->A);
                const_resource B(this->B);
                resource C(this->C);

                // Further increasing block size to reduce memory access.
                constexpr uint ck = 4;
                constexpr uint cm = 4;

                assert(Nk % (bk * ck) == 0);
                assert(Nl % (bl) == 0);
                assert(Nm % (bm * cm) == 0);

                gpu_for_group(0, (Nk / bk / ck) * (Nm / bm / cm), [&](gpu_uint block) {
                    gpu_uint koff = block / (Nm / bm / cm) * bk * ck;
                    gpu_uint moff = block % (Nm / bm / cm) * bm * cm;
                    Matrix<wmma::matrix<c_float_type, bk, bm>, ck, cm> mc;

                    for (unsigned int sk = 0; sk < ck; ++sk)
                    {
                        for (unsigned int sm = 0; sm < cm; ++sm)
                        {
                            mc(sk, sm).fill(static_cast<c_float_type>(0));
                        }
                    }

                    gpu_for(0, Nl, bl, [&](gpu_uint loff) {
                        for (unsigned int sk = 0; sk < ck; ++sk)
                        {
                            for (unsigned int sm = 0; sm < cm; ++sm)
                            {
                                wmma::matrix<ab_float_type, bk, bl> ma(
                                    A.begin() + (koff + sk * bk) * Nl + loff, Nl, wmma::row_major);
                                wmma::matrix<ab_float_type, bl, bm> mb(
                                    B.begin() + loff * Nm + (moff + sm * bm), Nm, wmma::row_major);
                                mc(sk, sm) = multiply_add(ma, mb, mc(sk, sm));
                            }
                        }
                    });
                    for (unsigned int sk = 0; sk < ck; ++sk)
                    {
                        for (unsigned int sm = 0; sm < cm; ++sm)
                        {
                            mc(sk, sm).store(C.begin() + (koff + sk * bk) * Nm + (moff + sm * bm), Nm, wmma::row_major);
                        }
                    }
                });
            });
        }
    }

    void run(const string& name, kernel<void()>& kernel_use)
    {
        cout << "\n"
             << name << ". T_AB=" << goopax::pretty_typename(typeid(ab_float_type))
             << ", T_C=" << goopax::pretty_typename(typeid(c_float_type)) << endl;
        C.fill(numeric_limits<c_float_type>::quiet_NaN()).wait();

        for (uint count = 0; count < 3; ++count)
        {
            auto time_start = steady_clock::now();
            kernel_use().wait();
            auto time_end = steady_clock::now();

            Tdouble time = duration_cast<duration<double>>(time_end - time_start).count();
            auto FLOPS = Tdouble(NK()) * NL() * NM() * 2 / time;
            cout << "Did matrix multiplication in " << time << " seconds. Performance: " << FLOPS / 1E12 << " TFLOPS"
                 << endl;
        }

        {
            buffer_map A(this->A);
            buffer_map B(this->B);
            buffer_map C(this->C);

            Map<Matrix<ab_float_type, Dynamic, Dynamic, RowMajor>> TA(A.data(), Nk, Nl);
            Map<Matrix<ab_float_type, Dynamic, Dynamic, RowMajor>> TB(B.data(), Nl, Nm);
            Map<Matrix<c_float_type, Dynamic, Dynamic, RowMajor>> TC(C.data(), Nk, Nm);

            VectorX<double> rwant = TA.template cast<double>() * (TB.template cast<double>() * test_vector);
            VectorX<double> rhave = TC.template cast<double>() * test_vector;

            cout << "err=" << (rhave - rwant).norm() / rwant.norm() << endl;
        }
    }
};

template<typename ab_float_type, typename c_float_type>
void run_with_types(goopax_device device)
{
    matmul<ab_float_type, c_float_type> mat(device, NK(), NL(), NM());

    mat.run("kernel_simple", mat.kernel_simple);
    if (mat.kernel_tensor.get_impl() != nullptr)
    {
        mat.run("kernel_tensor", mat.kernel_tensor);
    }
}

int main(int argc, char** argv)
{
    init_params(argc, argv);

    for (auto device : devices(GOOPAX_DEBUG ? env_CPU : env_GPU))
    {
        cout << "testing device=" << device.name() << ", env=" << device.get_envmode() << endl;
        cout << "matrix sizes: matrix<T_AB, " << NK() << ", " << NL() << "> * matrix<T_AB, " << NL() << "," << NM()
             << "> + matrix<T_C, " << NK() << "," << NM() << ">" << endl;
        if (device.support_type(Tdouble()))
        {
            run_with_types<Tdouble, Tdouble>(device);
        }
        run_with_types<Tfloat, Tfloat>(device);
        if (device.support_type(Thalf()))
        {
            run_with_types<Thalf, Thalf>(device);
            run_with_types<Thalf, Tfloat>(device);
        }
#ifdef __STDCPP_BFLOAT16_T__
        if (device.support_type(std::bfloat16_t()))
        {
            run_with_types<std::bfloat16_t, Tfloat>(device);
        }
#endif
        cout << endl << endl;
    }
}
