#!/bin/bash

set -e

if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
fi
export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release $CMAKE_FLAGS"

cmake $CMAKE_FLAGS -B build src --install-prefix "$PWD/dist"
cmake --build build --target eigen
cmake --build build --target sdl3
cmake --build build --target opencv

if  [ "$(uname -o)" == "Msys" ]; then
    echo "Not building boost and gmp on windows due to some difficulties"
else
    cmake --build build --target boost
#    cmake --build build --target gmp_tmp
fi
