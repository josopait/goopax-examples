ExternalProject_Add(
    sdl3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG main
    CMAKE_ARGS "-DBUILD_SHARED_LIBS=0" "-DSDL_SHARED=0" "-DSDL_STATIC=1" "-DSDL_ASSEMBLY=0" "--install-prefix ${CMAKE_INSTALL_PREFIX}/sdl3"
)