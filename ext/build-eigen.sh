#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

git submodule update src/eigen

cmake $CMAKE_FLAGS -B build/eigen src/eigen -DCMAKE_INSTALL_PREFIX="$PWD/dist/eigen"
cmake --build build/eigen --target install
