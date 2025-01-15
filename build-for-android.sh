#!/bin/bash

set -e

source ./android-ninja-config.sh

#export CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN)"

#export goopax_DIR="$PWD/../goopax-5.6.1-Android-aarch64"
#export CMAKE_PREFIX_PATH="$PWD/../goopax-5.6.1-Android-aarch64/lib"
CMAKE_FLAGS="$CMAKE_FLAGS -DGOOPAX_DRAW_WITH_OPENGL=0 -DGOOPAX_DRAW_WITH_METAL=0 -DCMAKE_FIND_ROOT_PATH=$PWD/../;$PWD/build/$build_type/$ABI/ext/boost;$PWD/build/$build_type/$ABI/ext/opencv;$PWD/build/$build_type/$ABI/ext/sdl3;$PWD/build/$build_type/$ABI/ext/eigen"

#requires cmake>=3.21
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake $CMAKE_FLAGS -B build/$build_type/$ABI -G "Ninja" src -DCMAKE_SYSTEM_NAME="Android" -DANDROID_ABI="$ABI" -DANDROID_PLATFORM="$platform_version_string" -DANDROID_NDK="$android_sdk/ndk/$ndk_version" -DCMAKE_TOOLCHAIN_FILE="$android_sdk/ndk/$ndk_version/build/cmake/android.toolchain.cmake"
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_eigen
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_sdl3
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_opencv
$HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI --target build_boost

if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    $HOME/Android/Sdk/cmake/3.22.1/bin/cmake --build build/$build_type/$ABI
    $HOME/Android/Sdk/cmake/3.22.1/bin/cmake --install build/$build_type/$ABI --prefix dist
fi
