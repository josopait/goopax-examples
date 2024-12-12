#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"
SDL_FLAGS="$SDL_FLAGS -DSDL_SHARED=0 -DSDL_STATIC=1 -DSDL_ASSEMBLY=0"
if  [ "$(uname -o)" == "Msys" ]; then
    SDL_FLAGS="$SDL_FLAGS -DSDL_RENDER_D3D=0 -DSDL_RENDER_D3D11=0 -DSDL_RENDER_D3D12=0 -DSDL_OPENGL=1 -DSDL_OPENGLES=0 -DSDL_GPU=0"
fi

if [ ! -d src/sdl3 ]; then
    git clone https://github.com/libsdl-org/SDL.git src/sdl3
fi

cmake $CMAKE_FLAGS -B build/sdl3 src/sdl3 $SDL_FLAGS -DCMAKE_INSTALL_PREFIX="$PWD/dist/sdl3"
cmake --build build/sdl3 --target install
