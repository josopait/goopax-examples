#!/bin/bash

set -e

export ABI="x86_64"
export platform_version_string="android-31"
export android_sdk="$HOME/Android/Sdk"
export ndk_version="27.2.12479018"

CMAKE_FLAGS="$CMAKE_FLAGS -DBUILD_SHARED_LIBS=0"

mkdir -p src
if [ ! -d src/eigen ]; then
    git clone https://gitlab.com/libeigen/eigen.git src/eigen -b 3.4.0
fi

#requires cmake>=3.21
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake $CMAKE_FLAGS -B build/eigen/debug/$ABI -G "Ninja" -H src/eigen -DCMAKE_SYSTEM_NAME="Android" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM="$platform_version_string" -DANDROID_NDK="$android_sdk/ndk/$ndk_version" -DCMAKE_TOOLCHAIN_FILE="$android_sdk/ndk/$ndk_version/build/cmake/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX="$PWD/dist/eigen"
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/eigen/debug/$ABI --target install

unset -v ABI
unset -v platform_version_string
unset -v android_sdk
unset -v ndk_version
