#!/bin/bash

set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

mkdir -p src
if [ ! -d src/eigen ]; then
    git clone https://gitlab.com/libeigen/eigen.git src/eigen -b 3.4.0
fi

#requires cmake>=3.21
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake $CMAKE_FLAGS -B build/eigen/$build_type/$ABI -G "Ninja" src/eigen -DCMAKE_SYSTEM_NAME="Android" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM="$platform_version_string" -DANDROID_NDK="$android_sdk/ndk/$ndk_version" -DCMAKE_TOOLCHAIN_FILE="$android_sdk/ndk/$ndk_version/build/cmake/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX="$PWD/dist/eigen"
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/eigen/$build_type/$ABI --target install
