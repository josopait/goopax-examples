#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_ITT=0 -DBUILD_PERF_TESTS=0 -DBUILD_TESTS=0 -DBUILD_opencv_apps=0 -DWITH_PROTOBUF=0 -DWITH_QUIRC=1 -DWITH_LAPACK=0 -DWITH_CUDA=0 -DBUILD_opencv_dnn=0 -DWITH_IPP=0 -DWITH_OPENEXR=0   -DWITH_JPEG=0 -DWITH_OPENJPEG=0 -DWITH_TIFF=0 -DWITH_FFMPEG=0 -DBUILD_SHARED_LIBS=0"

export Eigen3_DIR=dist/eigen

git submodule update --recursive src/opencv

cmake $CMAKE_FLAGS -B build/opencv src/opencv -DCMAKE_INSTALL_PREFIX="$PWD/dist/opencv"
cmake --build build/opencv --target install
