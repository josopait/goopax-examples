#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

git submodule update src/sdl2

cmake $CMAKE_FLAGS -B build/sdl2 src/sdl2 -DSDL_SHARED=0 -DSDL_STATIC=1 -DSDL_ASSEMBLY=0 -DCMAKE_INSTALL_PREFIX="$PWD/dist/sdl2"
cmake --build build/sdl2 --target install
