#!/bin/bash

set -e

./download-eigen.sh

cmake $CMAKE_FLAGS -B build .
cmake --build build/eigen
#There is a install target for a header-only lib
cmake --install build/eigen --prefix dist/eigen
