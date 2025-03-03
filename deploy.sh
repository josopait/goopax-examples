#!/bin/bash
adb push build/libsimple_LIBRARY.so /data/local/tmp
#adb push build/libsvm-pingpong_LIBRARY.so /data/local/tmp
adb push build/libpi_LIBRARY.so /data/local/tmp
#adb push build/librace-condition_LIBRARY.so /data/local/tmp
adb push build/libmatmul_LIBRARY.so /data/local/tmp
adb push build/libmemory-transfer_LIBRARY.so /data/local/tmp
adb push build/libmandelbrot_LIBRARY.so /data/local/tmp
#adb push build/libdeep-zoom-mandelbrot_LIBRARY.so /data/local/tmp
adb push build/libhelloworld_LIBRARY.so /data/local/tmp
adb push build/libgather_LIBRARY.so /data/local/tmp
adb push ../goopax-5.7.0-Android-aarch64/lib/libgoopax.so /data/local/tmp
