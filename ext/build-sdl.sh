#!/bin/bash

set -e

./download-sdl.sh

cmake $CMAKE_FLAGS -B build .
cmake --build build/sdl2
#There is no install target for a static lib
#cmake --install build/sdl2 --prefix dist/sdl2
