#invoking with -B requires 3.13
#FetchContent_MakeAvailable requires 3.14
#invoking with --install-prefix requires 3.21
if (WIN32)
cmake_minimum_required (VERSION 3.14)
include(ExternalProject)
include(ext/Eigen.cmake)
include(FetchContent)
set(CMAKE_POSITION_INDEPENDENT_CODE_save CMAKE_POSITION_INDEPENDENT_CODE)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
include(ext/SDL.cmake)
set(CMAKE_POSITION_INDEPENDENT_CODE CMAKE_POSITION_INDEPENDENT_CODE_save)
unset(CMAKE_POSITION_INDEPENDENT_CODE_save)
add_subdirectory(src)
endif (WIN32)
