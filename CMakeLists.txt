cmake_minimum_required(VERSION 3.21)

project(external-libraries LANGUAGES CXX)

include(ExternalProject)

include(src/cmake/Eigen.cmake)
include(src/cmake/SDL3.cmake)
include(src/cmake/OpenCV.cmake)
if (NOT WIN32)
  include(src/cmake/Boost.cmake)
  include(src/cmake/GMP.cmake)
endif()