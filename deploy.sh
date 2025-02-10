#!/bin/bash
adb push build/simple /data/local/tmp
#adb push build/svm-pingpong /data/local/tmp
adb push build/pi /data/local/tmp
#adb push build/race-condition /data/local/tmp
adb push build/matmul /data/local/tmp
adb push build/memory-transfer /data/local/tmp
#adb push build/mandelbrot /data/local/tmp
#adb push build/deep-zoom-mandelbrot /data/local/tmp
adb push build/helloworld /data/local/tmp
adb push build/gather /data/local/tmp
adb push ../goopax-5.7.0-Android-aarch64/lib/libgoopax.so /data/local/tmp
