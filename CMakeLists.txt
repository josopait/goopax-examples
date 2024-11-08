#invoking with -B requires 3.13
#invoking with --install-prefix requires 3.21
cmake_minimum_required (VERSION 3.13)
#for-all
set(CMAKE_POSITION_INDEPENDENT_CODE_save CMAKE_POSITION_INDEPENDENT_CODE)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
include(SDL.cmake)
set(CMAKE_POSITION_INDEPENDENT_CODE CMAKE_POSITION_INDEPENDENT_CODE_save)
unset(CMAKE_POSITION_INDEPENDENT_CODE_save)
#project-wise
#set_property(TARGET SDL2-static PROPERTY POSITION_INDEPENDENT_CODE ON)
add_subdirectory(src)
