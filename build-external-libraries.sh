#!/bin/bash

set -e

if  [ "$(uname -o)" == "Msys" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CONFIGURATION_TYPES=Debug -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
fi
export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release $CMAKE_FLAGS"

./ext/build-eigen.sh
./ext/build-sdl.sh
./ext/build-opencv.sh

if  [ "$(uname -o)" == "Msys" ]; then
    echo "Not building boost and gmp on windows due to some difficulties"
else
    ./ext/build-boost.sh
    ./ext/build-gmp.sh
fi
