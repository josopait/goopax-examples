#!/bin/bash

set -e

export CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN)"

if  [ "$(uname -o)" == "Msys" ]; then
	CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug -DOpenCV_STATIC=ON"
fi

cmake $CMAKE_FLAGS -B build src --install-prefix "$PWD/dist"
cmake --build build --target build_eigen
cmake --build build --target build_sdl3
cmake --build build --target build_opencv
if  [ ! "$(uname -o)" == "Msys" ]; then
  cmake --build build --target build_boost
  cmake --build build --target build_gmp
fi
cmake build
cmake --build build


if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build --prefix dist
fi
