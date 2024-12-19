#!/bin/bash

set -e

export goopax_DIR="$PWD/.."
if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
fi
export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release $CMAKE_FLAGS"

cmake $CMAKE_FLAGS -B src/build src --install-prefix "$PWD/dist"
if [ ! -d tmp/eigen ]; then
    ./ext/build-eigen.sh
fi
if [ ! -d tmp/sdl3 ]; then
    ./ext/build-sdl.sh
fi
if [ ! -d tmp/opencv ]; then
    ./ext/build-opencv.sh
fi

if  [ "$(uname -o)" == "Msys" ]; then
    echo "Not building boost and gmp on windows due to some difficulties"
else
    if [ ! -d tmp/boost ]; then
        ./ext/build-boost.sh
    fi
    if [ ! -d tmp/gmp ]; then
        ./ext/build-gmp.sh
    fi
fi
