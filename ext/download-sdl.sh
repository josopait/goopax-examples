#!/bin/bash

if [ ! -d src/sdl2 ]; then
    git clone https://github.com/libsdl-org/SDL.git src/sdl2 -b release-2.26.2
fi
