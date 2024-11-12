#!/bin/bash

mkdir -p src
if [ ! -d src/eigen ]; then
    git clone https://gitlab.com/libeigen/eigen.git src/eigen -b 3.4.0
fi
