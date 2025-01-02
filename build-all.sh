#!/bin/bash

set -e

export CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN)"

if  [ "$(uname -o)" == "Msys" ]; then
	CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug -DOpenCV_STATIC=ON"
fi

if (pwd | grep -- '-iOS/examples'); then
    MIN_IOS_VERSION=15
    echo "Building for ios."
    export CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS_VERSION -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=$MIN_IOS_VERSION -G Xcode"

    if [ -z ${APPLE_DEVELOPER_TEAM+x} ]; then
	echo "APPLE_DEVELOPER_TEAM is unset. See README.txt"
	exit 1
    fi
fi

cmake $CMAKE_FLAGS -B build src -DCMAKE_INSTALL_PREFIX="$PWD/dist"
cmake --build build --target build_external_libraries
cmake build
cmake --build build


if (echo "$CMAKE_FLAGS" | grep CMAKE_SYSTEM_NAME=iOS); then
    echo "iOS. Skipping install. Please open build/goopax_examples.xcodeproj and build manually."
else
    cmake --install build
fi
