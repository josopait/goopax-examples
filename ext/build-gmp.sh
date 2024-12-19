#!/bin/bash

set -e

PREFIX="$PWD/tmp/gmp"

export CFLAGS="$MAKEFILE_CFLAGS"
export CC="$MAKEFILE_CC"

mkdir -p ext/src
curl https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz -o ext/src/gmp-6.3.0.tar.xz
shasum -a 256 ext/src/gmp-6.3.0.tar.xz | grep a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898

mkdir -p ext/build
cd ext/build
tar -xf ../src/gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure $MAKEFILE_CONFIGURE_FLAGS --prefix="$PREFIX" --enable-static --disable-shared
make -j10 install
