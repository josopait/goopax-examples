#include "window_sdl.h"

//#define HAVE_GL 0
#define HAVE_METAL 1


#ifdef __linux__
#include <GL/glx.h>
#endif
#include <goopax>

using namespace Eigen;
using namespace goopax;
using namespace std;

void print_properties(unsigned int props)
{
    SDL_EnumerateProperties(
        props,
        [](void* userdata, SDL_PropertiesID props, const char* name) {
            cout << name << ": ";

            auto type = SDL_GetPropertyType(props, name);

            if (type == SDL_PROPERTY_TYPE_POINTER)
            {
                cout << SDL_GetPointerProperty(props, name, nullptr);
            }
            else if (type == SDL_PROPERTY_TYPE_STRING)
            {
                cout << SDL_GetStringProperty(props, name, "");
            }
            else if (type == SDL_PROPERTY_TYPE_NUMBER)
            {
                cout << SDL_GetNumberProperty(props, name, -1);
            }
            else if (type == SDL_PROPERTY_TYPE_FLOAT)
            {
                cout << SDL_GetFloatProperty(props, name, numeric_limits<float>::quiet_NaN());
            }
            else if (type == SDL_PROPERTY_TYPE_BOOLEAN)
            {
                cout << SDL_GetBooleanProperty(props, name, false);
            }
            else
            {
                cout << "BAD TYPE";
            }
            cout << endl;
        },
        nullptr);
}

std::array<unsigned int, 2> sdl_window::get_size() const
{
    int width;
    int height;
    SDL_GetWindowSize(window, &width, &height);
    return {(unsigned  int) width, (unsigned int)height };
}

std::optional<SDL_Event> sdl_window::get_event()
{
    SDL_Event e;
    if (SDL_PollEvent(&e) != 0)
    {
        return e;
    }
    else
    {
        return {};
    }
}

std::optional<SDL_Event> sdl_window::wait_event()
{
    SDL_Event e;
    if (SDL_WaitEvent(&e))
    {
        return e;
    }
    else
    {
        throw std::runtime_error(SDL_GetError());
    }
}

void sdl_window::set_title(const std::string& title) const
{
    SDL_SetWindowTitle(window, title.c_str());
}

void sdl_window::draw_goopax(std::function<void(image_buffer<2, Vector<Tuint8_t, 4>, true>& image)> func)
{
    draw_goopax_impl(func);
}


std::unique_ptr<sdl_window> sdl_window::create(const char* name, Eigen::Vector<Tuint, 2> size, uint32_t flags)
{
#if WITH_METAL
    try
    {
        cout << "Trying metal." << endl;
        return create_sdl_window_metal(name, size, flags);
    }
    catch(std::exception& e)
    {
        cout << "Got exception '" << e.what() << "'" << endl;
    }
#endif
#if WITH_OPENGL
    try
    {
        cout << "Trying opengl." << endl;
        return std::make_unique<sdl_window_gl>(name, size, flags);
    }
    catch(std::exception& e)
    {
        cout << "Got exception '" << e.what() << "'" << endl;
    }
#endif
    
    throw std::runtime_error("Failed to open window");
}

sdl_window::sdl_window(const char* name, Vector<Tuint, 2> size, uint32_t flags, const char* renderer_name)
{
    static std::once_flag once;
    call_once(once, []() {
        if (!SDL_Init(SDL_INIT_VIDEO))
        {
            throw std::runtime_error(SDL_GetError());
        }
    });

    std::atexit([]() { SDL_Quit(); });

    
    window = SDL_CreateWindow(name,    // window title
                              size[0], // width, in pixels
                              size[1], // height, in pixels
                              flags    /*| SDL_WINDOW_OPENGL */
    );
    if (window == nullptr)
    {
        throw std::runtime_error(std::string("Cannot create window: ") + SDL_GetError());
    }

    SDL_PropertiesID props = SDL_CreateProperties();

    bool ok  = SDL_SetStringProperty(props, SDL_PROP_RENDERER_CREATE_NAME_STRING, renderer_name);
    ok = ok && SDL_SetPointerProperty(props, SDL_PROP_RENDERER_CREATE_WINDOW_POINTER, window);
    assert(ok);
    
    renderer = SDL_CreateRendererWithProperties(props);

    SDL_DestroyProperties(props);

    if (renderer == nullptr)
    {
        SDL_DestroyWindow(window);
        window = nullptr;
        throw std::runtime_error(std::string("Cannot create renderer: ") + SDL_GetError());
    }

    cout << "renderer properties:" << endl;
    print_properties(SDL_GetRendererProperties(renderer));

    string renderer_name_check =
        SDL_GetStringProperty(SDL_GetRendererProperties(renderer), SDL_PROP_RENDERER_NAME_STRING, "");

    cout << "renderer name: " << renderer_name_check
    << ". should be " << renderer_name
    << endl;
    assert(renderer_name_check == renderer_name);

//    image.assign(gl_device, { 0, 0 });
}

sdl_window::~sdl_window()
{
    if (texture != nullptr)
    {
        SDL_DestroyTexture(texture);
        texture = nullptr;
    }
    if (renderer != nullptr)
    {
        SDL_DestroyRenderer(renderer);
        renderer = nullptr;
    }
    if (window != nullptr)
    {
        SDL_DestroyWindow(window);
        window = nullptr;
    }
}

#if WITH_OPENGL

void sdl_window_gl::draw_goopax_impl(std::function<void(image_buffer<2, Eigen::Vector<uint8_t, 4>, true>& image)> func)
{
    std::array<unsigned int, 2> size = get_size();

    if (size != image.dimensions())
    {
        // Either the first call, or the window size has changed. Re-allocating buffers.
        if (texture != nullptr)
        {
            SDL_DestroyTexture(texture);
            texture = nullptr;
        }
        
        texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA32, SDL_TEXTUREACCESS_TARGET, size[0], size[1]);
        if (texture == nullptr)
        {
            throw std::runtime_error(std::string("Cannot create texture: ") + SDL_GetError());
        }
        
        SDL_PropertiesID texture_props = SDL_GetTextureProperties(texture);
        
        cout << "\ntexture_props:" << endl;
        print_properties(texture_props);
        
        string renderer_name =
        SDL_GetStringProperty(SDL_GetRendererProperties(renderer), SDL_PROP_RENDERER_NAME_STRING, "");
        if (renderer_name == "opengl")
        {
            unsigned int gl_id = SDL_GetNumberProperty(texture_props, SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER, 123);
            image = image_buffer<2, Eigen::Vector<uint8_t, 4>, true>::create_from_gl(device, gl_id);
        }
        else
        {
            throw std::runtime_error("Not implemented: renderer " + renderer_name);
        }
        
        SDL_DestroyProperties(texture_props);
        
    }

    if  (false)
    {
        SDL_FRect r;
        r.w = 100;
        r.h = 50;
        
        r.x=rand()%500;
        r.y=rand()%500;
        
        SDL_SetRenderTarget(renderer, texture);
        SDL_SetRenderDrawColor(renderer, 0x00, 0xFF, 0x00, 0xFF);
        SDL_RenderClear(renderer);
        SDL_RenderRect(renderer,&r);
        SDL_SetRenderDrawColor(renderer, 0xFF, 0x00, 0x00, 0xFF);
        SDL_RenderFillRect(renderer, &r);
    }
    else
    {
        func(image);
#if HAVE_GL
        flush_gl_interop(gl_device);
#endif
    }
    SDL_SetRenderTarget(renderer, nullptr);
    bool ret = SDL_RenderTexture(renderer, texture, nullptr, nullptr);
    if (!ret)
    {
        throw std::runtime_error(std::string("SDL_RenderTexture failed: ") + SDL_GetError());
    }

    SDL_RenderPresent(renderer);
}

sdl_window_gl::sdl_window_gl(const char* name, Vector<Tuint, 2> size, uint32_t flags) :
sdl_window(name, size, flags | SDL_WINDOW_OPENGL, "opengl")
{
    auto devices = goopax::get_devices_from_gl();
    if  (devices.empty())
    {
        throw std::runtime_error("Cannot create goopax device for opengl");
    }

    this->image.assign(devices[0], {0,0});
    cout << "devices.size()=" << devices.size() << endl;
    this->device = devices[0];
    cout << "Using device " << this->device.name() << ", env=" << this->device.get_envmode() << endl;
}

#endif
