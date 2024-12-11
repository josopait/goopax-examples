#export Eigen3_DIR=dist/eigen
ExternalProject_Add(
    opencv
    GIT_REPOSITORY https://github.com/opencv/opencv.git
    GIT_TAG 4.10.0
    GIT_SUBMODULES_RECURSE 1
    CMAKE_ARGS
      "-DBUILD_SHARED_LIBS=0"
      "-DBUILD_ITT=0"
      "-DBUILD_PERF_TESTS=0"
      "-DBUILD_TESTS=0"
      "-DBUILD_opencv_apps=0"
      "-DWITH_PROTOBUF=0"
      "-DWITH_QUIRC=1"
      "-DWITH_LAPACK=0"
      "-DWITH_CUDA=0"
      "-DBUILD_opencv_dnn=0"
      "-DWITH_IPP=0"
      "-DWITH_OPENEXR=0"
      "-DWITH_JPEG=0"
      "-DWITH_OPENJPEG=0"
      "-DWITH_TIFF=0"
      "-DWITH_FFMPEG=0"
      "--install-prefix ${CMAKE_INSTALL_PREFIX}/opencv"
)
