#!/bin/bash

set -e

export CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN)"

cmake "$@" -B build src
cmake --build build --target build_glatter
cmake --build build --target build_eigen
cmake --build build --target build_sdl3
#cmake --build build --target build_opencv
cmake --build build --target build_boost
cmake build
cmake --build build
