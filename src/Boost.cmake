ExternalProject_Add(
    boost
    EXCLUDE_FROM_ALL 1
    STEP_TARGETS build install
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    GIT_TAG boost-1.86.0
    GIT_SUBMODULES_RECURSE 1
    CMAKE_ARGS "-DBUILD_SHARED_LIBS=0" "--install-prefix ${CMAKE_INSTALL_PREFIX}/boost"
)