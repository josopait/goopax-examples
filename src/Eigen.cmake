set(BUILD_SHARED_LIBS_save BUILD_SHARED_LIBS)
set(BUILD_SHARED_LIBS 0)
get_directory_property(PROPERTIES EP_BASE EP_BASE_save)
set_directory_properties(PROPERTIES EP_BASE "ext/eigen")
ExternalProject_Add(
    eigen
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG 3.4.0
)
set_directory_properties(PROPERTIES EP_BASE EP_BASE_save)
set(BUILD_SHARED_LIBS BUILD_SHARED_LIBS_save)
unset(BUILD_SHARED_LIBS_save)