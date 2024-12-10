set(BUILD_SHARED_LIBS_save BUILD_SHARED_LIBS)
set(BUILD_SHARED_LIBS 0)
ExternalProject_Add(
    eigen
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG 3.4.0
    PREFIX "ext"
    BINARY_DIR "ext/build/eigen"
)
set(BUILD_SHARED_LIBS BUILD_SHARED_LIBS_save)
unset(BUILD_SHARED_LIBS_save)