#invoking with -B requires 3.13
#invoking with --install-prefix requires 3.21
cmake_minimum_required (VERSION 3.13)
#set(CMAKE_MSVC_RUNTIME_LIBRARY_save CMAKE_MSVC_RUNTIME_LIBRARY)
#set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
include(Eigen.cmake)
##OpenCV needs Eigen3_DIR from above set to the cmake files
##message(FATAL_ERROR, "Advisory: OpenCV 4.10.0 is downloading 3rdparty ade even though gapi is disabled.")
#include(OpenCV.cmake)
#if (MSYS)
#message(WARNING, "Not building boost and gmp on windows due to some difficulties.")
#else (MSYS)
#include(GMP.cmake)
##Boost comes after all the others because of a missing file
#include(Boost.cmake)
#endif (MSYS)
#set(CMAKE_MSVC_RUNTIME_LIBRARY CMAKE_MSVC_RUNTIME_LIBRARY_save)
#unset(CMAKE_MSVC_RUNTIME_LIBRARY_save)
