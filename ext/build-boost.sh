#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

mkdir -p src
if [ ! -d ext/src/boost ]; then
    git clone https://github.com/boostorg/boost.git ext/src/boost -b boost-1.86.0 --recurse-submodules
fi

cmake $CMAKE_FLAGS -B ext/build/boost ext/src/boost -DCMAKE_INSTALL_PREFIX="$PWD/tmp/boost"
cmake --build ext/build/boost --target install
