#invoking with -B requires 3.13
#invoking with --install-prefix requires 3.21
cmake_minimum_required (VERSION 3.13)
#set(CMAKE_MSVC_RUNTIME_LIBRARY_save CMAKE_MSVC_RUNTIME_LIBRARY)
#set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
include(Eigen.cmake)
#set(CMAKE_MSVC_RUNTIME_LIBRARY CMAKE_MSVC_RUNTIME_LIBRARY_save)
#unset(CMAKE_MSVC_RUNTIME_LIBRARY_save)
