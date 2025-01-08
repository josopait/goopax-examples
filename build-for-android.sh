#!/bin/bash

set -e

source ./android-ninja-config.sh

#export goopax_DIR="$PWD/../goopax-5.6.1-Linux-x86_64/share/goopax/cmake"
#export CMAKE_PREFIX_PATH="$PWD/../goopax-5.6.1-Linux-x86_64/lib"

#requires cmake>=3.21
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake $CMAKE_FLAGS -B build/$build_type/$ABI -G "Ninja" src -DCMAKE_SYSTEM_NAME="Android" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM="$platform_version_string" -DANDROID_NDK="$android_sdk/ndk/$ndk_version" -DCMAKE_TOOLCHAIN_FILE="$android_sdk/ndk/$ndk_version/build/cmake/android.toolchain.cmake" --install-prefix="$PWD/tmp"
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_eigen
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_sdl3
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_opencv
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_boost
#$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_gmp

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    $HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI
    $HOME/Android/Sdk/cmake/3.22.1/bin/cmake --install build/$build_type/$ABI --prefix dist
fi
