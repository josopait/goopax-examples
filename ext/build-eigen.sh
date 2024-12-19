#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

mkdir -p ext/src
if [ ! -d ext/src/eigen ]; then
    git clone https://gitlab.com/libeigen/eigen.git ext/src/eigen -b 3.4.0
fi

cmake $CMAKE_FLAGS -B ext/build/eigen ext/src/eigen -DCMAKE_INSTALL_PREFIX="$PWD/tmp/eigen"
cmake --build ext/build/eigen --target install
