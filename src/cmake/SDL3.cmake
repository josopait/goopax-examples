if (WIN32)
ExternalProject_Add(
    sdl3_gpx
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG main
    EXCLUDE_FROM_ALL 1
    CMAKE_ARGS "-DCMAKE_CONFIGURATION_TYPES=Debug" "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug"
      "-DBUILD_SHARED_LIBS=0"
      "-DSDL_SHARED=0"
      "-DSDL_STATIC=1"
      "-DSDL_ASSEMBLY=0"
      "-DSDL_RENDER_D3D=0"
      "-DSDL_RENDER_D3D11=0"
      "-DSDL_RENDER_D3D12=0"
      "-DSDL_OPENGL=1"
      "-DSDL_OPENGLES=0"
      "-DSDL_GPU=0"
      "-DSDL_STATIC_PIC=ON"
      "--install-prefix ${CMAKE_INSTALL_PREFIX}/../tmp/sdl3"
#      INSTALL_COMMAND ""
)
else()
ExternalProject_Add(
    sdl3_gpx
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG main
    EXCLUDE_FROM_ALL 1
    CMAKE_ARGS
      "-DBUILD_SHARED_LIBS=0"
      "-DSDL_SHARED=0"
      "-DSDL_STATIC=1"
      "-DSDL_ASSEMBLY=0"
      "--install-prefix ${CMAKE_INSTALL_PREFIX}/../tmp/sdl3"
#    INSTALL_COMMAND ""
)
endif()
