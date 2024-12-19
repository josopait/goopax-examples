if (WIN32)
ExternalProject_Add(
    eigen_gpx
    EXCLUDE_FROM_ALL 1
    STEP_TARGETS build install
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG 3.4.0
    CMAKE_ARGS "-DCMAKE_CONFIGURATION_TYPES=Debug" "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
      "-DBUILD_SHARED_LIBS=0"
      "--install-prefix ${CMAKE_INSTALL_PREFIX}/../tmp/eigen"
)
else()
ExternalProject_Add(
    eigen_gpx
    EXCLUDE_FROM_ALL 1
    STEP_TARGETS build install
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG 3.4.0
    CMAKE_ARGS
      "-DBUILD_SHARED_LIBS=0"
      "--install-prefix ${CMAKE_INSTALL_PREFIX}/../tmp/eigen"
)
endif()
