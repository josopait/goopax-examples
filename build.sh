#!/bin/bash

set -e

source ./ninja-config.sh

export goopax_DIR="$PWD/.."
#export SDL2_DIR=ext/dist/sdl2
export Eigen3_DIR=ext/dist/eigen
#export OpenCV_DIR=ext/dist/opencv
#export Boost_DIR=ext/dist/boost
#export CMAKE_PREFIX_PATH="$PWD/ext/dist/gmp"

if  [ "$(uname -o)" == "Msys" ]; then
	CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug" -DOpenCV_STATIC=ON
fi

#requires cmake>=3.21
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake $CMAKE_FLAGS -B build/$build_type/$ABI -G "Ninja" src -DCMAKE_SYSTEM_NAME="Android" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM="$platform_version_string" -DANDROID_NDK="$android_sdk/ndk/$ndk_version" -DCMAKE_TOOLCHAIN_FILE="$android_sdk/ndk/$ndk_version/build/cmake/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX="$PWD/dist"

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    $HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target install
fi
