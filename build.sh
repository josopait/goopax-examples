#!/bin/bash

set -e

export goopax_DIR="$PWD/.."
if [ -d tmp/eigen ]; then
    export Eigen3_DIR=tmp/eigen
fi
if [ -d tmp/sdl3 ]; then
    export SDL3_DIR=tmp/sdl3
fi
if [ -d tmp/opencv ]; then
    export OpenCV_DIR=tmp/opencv
fi

if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug -DOpenCV_STATIC=ON"
else
    if [ -d tmp/boost ]; then
        export Boost_DIR=tmp/boost
    fi
    if [ -d tmp/gmp ]; then
        export CMAKE_PREFIX_PATH="$PWD/tmp/gmp"
    fi
fi

cmake $CMAKE_FLAGS -DGOOPAX_EXAMPLES_BUILD_MISSING_LIBRARIES=0 -B src/build src --install-prefix "$PWD/dist"

cmake --build src/build

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install src/build --prefix dist
fi
