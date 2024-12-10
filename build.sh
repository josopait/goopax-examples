#!/bin/bash

set -e

export goopax_DIR="$PWD/.."
export Eigen3_DIR=build/ext/build/eigen
export OpenCV_DIR=ext/dist/opencv

export goopax_DIR="$PWD/.."
if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug -DOpenCV_STATIC=ON"
    cmake $CMAKE_FLAGS -B build .
else
    export Boost_DIR=ext/dist/boost
    export CMAKE_PREFIX_PATH="$PWD/ext/dist/gmp"
    cmake $CMAKE_FLAGS -B build src
fi

cmake --build build

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build --prefix dist
fi
