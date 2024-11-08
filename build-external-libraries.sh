#!/bin/bash

set -e

mkdir -p ext/src
if [ ! -d ext/src/eigen ]; then
    git clone https://gitlab.com/libeigen/eigen.git ext/src/eigen -b 3.4.0
fi

export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release $CMAKE_FLAGS"

cmake $CMAKE_FLAGS -B ext/build ext
cmake --build ext/build
#There is a install target for a header-only lib
cmake --install ext/build/eigen --prefix ext/dist/eigen
