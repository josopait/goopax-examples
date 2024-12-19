#!/bin/bash

set -e

export goopax_DIR="$PWD/.."
if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
fi
export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release $CMAKE_FLAGS"

cmake $CMAKE_FLAGS -B build . --install-prefix "$PWD/dist"
if [ ! -d tmp/eigen ]; then
    cmake --build build --target eigen_gpx
fi
if [ ! -d tmp/sdl3 ]; then
    cmake --build build --target sdl3_gpx
fi
if [ ! -d tmp/opencv ]; then
    cmake --build build --target opencv_gpx
fi

if  [ "$(uname -o)" == "Msys" ]; then
    echo "Not building boost and gmp on windows due to some difficulties"
else
    if [ ! -d tmp/boost ]; then
        cmake --build build --target boost_gpx
    fi
    if [ ! -d tmp/gmp ]; then
        cmake --build build --target gmp_gpx
    fi
fi
