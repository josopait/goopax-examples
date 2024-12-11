#!/bin/bash

set -e

export goopax_DIR="$PWD/.."
export Eigen3_DIR=ext/dist/eigen
export SDL3_DIR=ext/dist/sdl3
export OpenCV_DIR=ext/dist/opencv

export goopax_DIR="$PWD/.."
if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug -DOpenCV_STATIC=ON"
else
    export Boost_DIR=ext/dist/boost
    export CMAKE_PREFIX_PATH="$PWD/ext/dist/gmp;$PWD/dist/gmp"
fi

cmake $CMAKE_FLAGS -B build src --install-prefix "$PWD/dist"

cmake --build build

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build --prefix dist
fi
