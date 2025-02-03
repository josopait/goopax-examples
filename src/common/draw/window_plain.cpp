#include "window_plain.h"
using namespace goopax;
using namespace std;

void sdl_window_plain::draw_goopax(std::function<void(image_buffer<2, Eigen::Vector<Tuint8_t, 4>, true>& image)> func)
{
    SDL_Surface* surface = SDL_GetWindowSurface(window);
    if (surface == nullptr)
    {
        throw std::runtime_error(std::string("Cannot create surface: ") + SDL_GetError());
    }

    if (!SDL_LockSurface(surface))
    {
        throw std::runtime_error("SDL_LockSurface failed");
    }
    if (surface->pitch != surface->w * 4)
    {
        cerr << "Sorry, pixel layout not implemented: pitch=" << surface->pitch << ", width=" << surface->w << endl;
        throw std::runtime_error("pixel layout not implemented");
    }
    std::array<unsigned int, 2> size = { (unsigned int)surface->w, (unsigned int)surface->h };
    {
#if GOOPAX_DEBUG
        image_buffer<2, Eigen::Vector<Tuint8_t, 4>, true> image(device, size);
        func(image);
        vector<Tuint> data(size[0] * size[1]);
        image.copy_to_host(reinterpret_cast<Eigen::Vector<Tuint8_t, 4>*>(data.data()));
        std::copy(data.begin(), data.end(), static_cast<unsigned int*>(surface->pixels));
#else
        if (false)
        {
            // Mapping directly to surface pointer. Does not seem to work, except for env_CPU."
            image_buffer<2, Eigen::Vector<Tuint8_t, 4>, true> image(
                device, size, BUFFER_READ_WRITE, reinterpret_cast<Eigen::Vector<Tuint8_t, 4>*>(surface->pixels));
            func(image);
            device.wait_all();
        }
        else
        {
            image_buffer<2, Eigen::Vector<Tuint8_t, 4>, true> image(device, size);
            func(image);
            image.copy_to_host(reinterpret_cast<Eigen::Vector<Tuint8_t, 4>*>(surface->pixels));
        }
#endif
    }
    SDL_UnlockSurface(surface);
    SDL_UpdateWindowSurface(window);
    SDL_DestroySurface(surface);
}

sdl_window_plain::sdl_window_plain(const char* name, Eigen::Vector<Tuint, 2> size, uint32_t flags)
    : sdl_window(name, size, flags, nullptr)
{
#if GOOPAX_DEBUG
    this->device = goopax::default_device(env_CPU);
#else
    this->device = goopax::default_device(env_ALL);
#endif
    if (!device.valid())
    {
        throw std::runtime_error("Cannot create goopax device for plain drawing");
    }

    cout << "Using device " << this->device.name() << ", env=" << this->device.get_envmode() << endl;
}
