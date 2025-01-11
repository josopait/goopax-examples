#include <goopax_extra/random.hpp>
#include <random>

#include "common/draw/types.h"
#include <goopax_extra/param.hpp>
using namespace Eigen;

#include <cassert>
#include <goopax>
#if defined(GOOPAX_USE_BOOST) && GOOPAX_USE_BOOST
#include <boost/chrono.hpp>
using namespace boost::chrono;
#else
#include <chrono>
using namespace std::chrono;
#endif
using namespace goopax;
using namespace std;

PARAMOPT<size_t> NK("nk", 2048); // Matrix sizes. Can be specified as command line arguments,
PARAMOPT<size_t> NL("nl", 2048); // e.g., --nk=128 --nl=256 --nm=384
PARAMOPT<size_t> NM("nm", 2048);

#ifdef _MSC_VER
#define vector std::vector
#endif

// GOOPAX currently does not provide 2-dimensional resource access. Implementing it here.

// The class matrix_wrapper provides matrix access to an arbitrary container class that has random-access iterators.
template<class RES>
struct matrix_wrapper
{
    RES res;
    using TYPE = typename std::remove_reference<RES>::type;
    using U = typename TYPE::size_type;

    const U height;
    const U width;

    typename TYPE::iterator operator[](const U& col)
    {
        return res.begin() + col * width;
    }

    typename TYPE::const_iterator operator[](const U& col) const
    {
        return res.begin() + col * width;
    }

    template<class... ARGS>
    matrix_wrapper(const U& height0, const U& width0, ARGS... args)
        : res(args...)
        , // Any additional arguments are passed to the constructor of RES.
        height(height0)
        , width(width0)
    {
    }

    matrix_wrapper(const U& height0, const U& width0, RES res0)
        : res(res0)
        , // Any additional arguments are passed to the constructor of RES.
        height(height0)
        , width(width0)
    {
    }
};

template<typename RES>
ostream& operator<<(ostream& s, const matrix_wrapper<RES>& m)
{
    for (Tsize_t y = 0; y < m.height; ++y)
    {
        for (Tsize_t x = 0; x < m.width; ++x)
        {
            if (x != 0)
                s << " ";
            s << m.res[y * m.width + x];
        }
        s << endl;
    }
    return s;
}

// Naive implementation of a matrix multiplication.
template<class float_type>
void matmul_naive(matrix_wrapper<resource<float_type>&>& C,
                  const matrix_wrapper<const resource<float_type>&>& A,
                  const matrix_wrapper<const resource<float_type>&>& B)
{
    using gpu_float_type = typename make_gpu<float_type>::type;

    gpu_for_global(0,
                   C.height * C.width,
                   [&](gpu_uint pos) // Parallel loop over all matrix elements
                   {
                       const gpu_uint k = pos / C.width;
                       const gpu_uint m = pos % C.width;

                       gpu_float_type Ctmp = 0;
                       gpu_for(0, A.width, [&](gpu_uint l) { Ctmp += A[k][l] * B[l][m]; });
                       C[k][m] = Ctmp;
                   });
}

// More sophisticated matrix multiplication. Uses registers to cache matrix elements.
// Good performance on AMD cards, poor performance on nvidia cards.
template<class float_type>
void matmul_reg(matrix_wrapper<resource<float_type>&>& C,
                const matrix_wrapper<const resource<float_type>&>& A,
                const matrix_wrapper<const resource<float_type>&>& B)
{
    using gpu_float_type = typename make_gpu<float_type>::type;

    // Block sizes. Using fine-tuned values here for simplicity. If not enough registers are available, these values
    // need to be reduced.
    Tuint B1k = 8;
    Tuint B1l = 2;
    Tuint B1m = 8;
    if (sizeof(float_type) == 8) // Adjustments for Tdouble precision.
    {
        B1k = 8;
        B1l = 1;
    }

    // Big parallel loop over all blocks in the result matrix C.
    gpu_for_group(0, C.height, B1k, [&](gpu_uint koffset) {
        gpu_for_local(0, C.width, B1m, [&](gpu_uint moffset) {
            // Caching the result block. Storing intermediate results in Ctmp as registers.
            Eigen::Matrix<gpu_float_type, Dynamic, Dynamic> Ctmp(B1k, B1m);
            Ctmp.fill(0);

            gpu_for(0, A.width, B1l, [&](gpu_uint loffset) {
                // Calculating the matrix product of the sub-blocks.
                // There is no need to prefetch the sub-blocks of A and B into registers:
                // The c-style for-loops are explicitly unrolled,
                // and redundant memory accesses are removed by common subexpression elimination.
                for (unsigned int ksub = 0; ksub < B1k; ++ksub)
                {
                    const gpu_uint k = koffset + ksub;
                    for (unsigned int msub = 0; msub < B1m; ++msub)
                    {
                        const gpu_uint m = moffset + msub;
                        for (Tuint lsub = 0; lsub < B1l; ++lsub)
                        {
                            const gpu_uint l = loffset + lsub;
                            Ctmp(ksub, msub) += A[k][l] * B[l][m];
                        }
                    }
                }
            });

            // Writing the result block.
            for (Tuint ksub = 0; ksub < B1k; ++ksub)
            {
                const gpu_uint k = koffset + ksub;
                for (Tuint msub = 0; msub < B1m; ++msub)
                {
                    const gpu_uint m = moffset + msub;
                    C[k][m] = Ctmp(ksub, msub);
                }
            }
        });
    });
}

// The following implementation uses two-level caching: Big blocks in local memory for work-groups, and small blocks in
// registers for individual threads. Good performance on nvidia cards, not so good performance on AMD cards.
template<class float_type>
void matmul_reg_and_localmem(matrix_wrapper<resource<float_type>&>& C,
                             const matrix_wrapper<const resource<float_type>&>& A,
                             const matrix_wrapper<const resource<float_type>&>& B)
{
    using gpu_float_type = typename make_gpu<float_type>::type;

    // Sizes of small blocks for register cache.
    Tuint B1k = 8;
    Tuint B1l = 2;
    Tuint B1m = 8;
    if (sizeof(float_type) == 8)
    {
        B1k = 8;
        B1l = 1;
    }

    // Sizes of big blocks for local memory cache. Assigning one block to every work-group.
    Tuint B2k = 1;
    while (B2k * B2k * 4 <= local_size())
    {
        B2k *= 2;
    }
    Tuint B2m = B2k;
    if (B2k * B2m < local_size())
        B2m *= 2;

    Tuint B2l = 16;
    if (sizeof(float_type) == 8)
        B2l = 8;
    assert(B2k * B2m == local_size());

    // Total big block sizes.
    const Tuint B12k = B1k * B2k;
    const Tuint B12l = B1l * B2l;
    const Tuint B12m = B1m * B2m;

    // Number of big blocks
    gpu_uint blocks_k = C.height / B12k;
    gpu_uint blocks_l = A.width / B12l;
    gpu_uint blocks_m = C.width / B12m;

    // Loop through all big blocks, parallelized over the work-groups.
    gpu_for_group(0, blocks_k * blocks_m, [&](gpu_uint pos3) {
        // The work-group handles big block k3,m3
        const gpu_uint k3 = pos3 / blocks_m;
        const gpu_uint m3 = pos3 % blocks_m;

        // The individual thread handles small block k2,m2 within the big block.
        const gpu_uint k2 = local_id() / B2m;
        const gpu_uint m2 = local_id() % B2m;

        // Caching the result block
        vector<vector<gpu_float_type>> Ctmp(B1k, vector<gpu_float_type>(B1m, 0));

        gpu_for(0, blocks_l, [&](gpu_uint l3) {
            // Allocating local memory.
            matrix_wrapper<local_mem<float_type>> Atmp(B12k, B12l, B12k * B12l);
            matrix_wrapper<local_mem<float_type>> Btmp(B12l, B12m, B12l * B12m);
            Tuint burstl = 2;
            Tuint burstm = 4;

            // Fetch memory into local memory.
            gpu_for_local(0, B12k * B12l, burstl, [&](gpu_uint pos12) {
                const gpu_uint k = pos12 / B12l;
                const gpu_uint l_start = pos12 % B12l;

                for (Tuint sub = 0; sub < burstl; ++sub)
                {
                    const gpu_uint l = l_start + sub;
                    Atmp[k][l] = A[k3 * B12k + k][l3 * B12l + l];
                }
            });
            gpu_for_local(0, B12l * B12m, burstm, [&](gpu_uint pos12) {
                const gpu_uint l = pos12 / B12m;
                const gpu_uint m_start = pos12 % B12m;

                for (Tuint sub = 0; sub < burstm; ++sub)
                {
                    const gpu_uint m = m_start + sub;
                    Btmp[l][m] = B[l3 * B12l + l][m3 * B12m + m];
                }
            });
            Atmp.res.barrier();
            Btmp.res.barrier();

            // Now calculate the contribution to sub-block k2,m2. Again, common subexpression elimination will remove
            // Redundand memory accesses, and most of the actual calculation is done in registers.
            gpu_for(0, B2l, [&](gpu_uint l2) {
                for (Tuint k = 0; k < B1k; ++k)
                {
                    for (Tuint m = 0; m < B1m; ++m)
                    {
                        for (Tuint l = 0; l < B1l; ++l)
                        {
                            Ctmp[k][m] += Atmp[k2 * B1k + k][l2 * B1l + l] * Btmp[l2 * B1l + l][m2 * B1m + m];
                        }
                    }
                }
            });
        });

        // Write the result.
        for (Tuint k = 0; k < B1k; ++k)
        {
            for (Tuint m = 0; m < B1m; ++m)
            {
                C[k3 * B12k + k2 * B1k + k][m3 * B12m + m2 * B1m + m] = Ctmp[k][m];
            }
        }
    });
}

// This is the kernel class.
template<typename ab_float_type, typename c_float_type>
struct matmul
{
    using gpu_ab_float_type = typename make_gpu<ab_float_type>::type;
    using gpu_c_float_type = typename make_gpu<c_float_type>::type;
    const unsigned int Nk;
    const unsigned int Nl;
    const unsigned int Nm;

    goopax_device device;
    buffer<ab_float_type> A;
    buffer<ab_float_type> B;
    buffer<c_float_type> C;

    std::random_device rd;
    WELL512_data rnd;
    kernel<void(buffer<ab_float_type>& a)> fill_random;
    VectorX<double> test_vector;

    kernel<void()> kernel_naive;
#if !GOOPAX_DEBUG
    kernel<void()> kernel_tensor;
#endif

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

        kernel_naive.assign(device, [this]() {
            const_resource A(this->A);
            const_resource B(this->B);
            resource C(this->C);

            gpu_for_group(0, Nk, [&](gpu_uint k) {
                gpu_for_local(0, Nm, [&](gpu_uint m) {
                    gpu_c_float_type sum = 0;
                    gpu_for(0, Nl, [&](gpu_uint l) {
                        sum += A[k * Nl + l] * static_cast<gpu_c_float_type>(B[l * Nm + m]);
                    });
                    C[k * Nm + m] = sum;
                });
            });
        });

#if !GOOPAX_DEBUG
        kernel_tensor.assign(device, [this]() {
            const_resource A(this->A);
            const_resource B(this->B);
            resource C(this->C);

            // sub-matrix sizes used in tensor cores
            constexpr uint bk = 16;
            constexpr uint bl = 16;
            constexpr uint bm = 16;

            // Further increasing block size to reduce memory access.
            constexpr uint ck = 4;
            constexpr uint cm = 4;

            assert(Nk % (bk * ck) == 0);
            assert(Nl % (bl) == 0);
            assert(Nm % (bm * cm) == 0);

            wmma::matrix<wmma::matrix_a, bk, bm, bl, ab_float_type> ma;
            wmma::matrix<wmma::matrix_b, bk, bm, bl, ab_float_type> mb;
            Matrix<wmma::matrix<wmma::accumulator, bk, bm, bl, c_float_type>, ck, cm> mc;
            gpu_for_group(0, (Nk / bk / ck) * (Nm / bm / cm), [&](gpu_uint block) {
                gpu_uint koff = block / (Nm / bm / cm) * bk * ck;
                gpu_uint moff = block % (Nm / bm / cm) * bm * cm;

                for (unsigned int sk = 0; sk < ck; ++sk)
                {
                    for (unsigned int sm = 0; sm < cm; ++sm)
                    {
                        mc(sk, sm).fill(0);
                    }
                }

                gpu_for(0, Nl, bl, [&](gpu_uint loff) {
                    for (unsigned int sk = 0; sk < ck; ++sk)
                    {
                        for (unsigned int sm = 0; sm < cm; ++sm)
                        {
                            ma.load(A.begin() + (koff + sk * bk) * Nl + loff, Nl);
                            mb.load(B.begin() + loff * Nm + (moff + sm * bm), Nm);
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
#endif
    }

    void run(kernel<void()>& kernel_use)
    {
        C.fill(numeric_limits<c_float_type>::quiet_NaN()).wait();

        Tsize_t count = 0;
        auto time_start = steady_clock::now();
        while (steady_clock::now() < time_start + seconds(1))
        {
            kernel_use();
            ++count;
            device.wait_all();
        }
        Tdouble time = duration_cast<duration<double>>(steady_clock::now() - time_start).count();
        auto FLOPS = Tdouble(NK()) * NL() * NM() * 2 * count / time;
        cout << "Did " << count << " matrix multiplications in " << time << " seconds. Performance: " << FLOPS / 1E12
             << " TFLOPS" << endl;

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

int main(int argc, char** argv)
{
    init_params(argc, argv);

#if GOOPAX_DEBUG
    goopax_device device = default_device(env_CPU);
#else
    goopax_device device = default_device();
#endif

    matmul<Thalf, Tfloat> mat(device, NK(), NL(), NM());

    cout << "\ntrying naive kernel." << endl;
    mat.run(mat.kernel_naive);
#if !GOOPAX_DEBUG
    cout << "\ntrying tensor kernel." << endl;
    mat.run(mat.kernel_tensor);
#endif
}
