#!/bin/bash

set -e

export CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN)"

cmake $CMAKE_FLAGS -B build src -DCMAKE_INSTALL_PREFIX="$PWD/dist"
cmake --build build --target build_eigen
cmake --build build --target build_sdl3
cmake --build build --target build_opencv
cmake --build build --target build_boost
cmake build
cmake --build build


if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build --prefix dist
fi
