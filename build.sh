#!/bin/bash

set -e

export Eigen3_DIR=ext/dist/eigen
mkdir -p ext/src
if [ ! -d ext/src/sdl2 ]; then
    git clone https://github.com/libsdl-org/SDL.git ext/src/sdl2 -b release-2.26.2
fi

export goopax_DIR="$PWD/.."
#Was SDL Release?
if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug" -DOpenCV_STATIC=ON
fi
cmake $CMAKE_FLAGS -B build .

cmake --build build

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build --prefix dist
fi
