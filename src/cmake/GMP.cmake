include(ExternalProject)
ExternalProject_Add(
  gmp_gpx
  EXCLUDE_FROM_ALL 1
  STEP_TARGETS build install
  URL https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
  URL_HASH "SHA256=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
  BUILD_IN_SOURCE 1
  CONFIGURE_HANDLED_BY_BUILD 1
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}/../tmp/gmp --enable-static --disable-shared
)
#set_property(TARGET gmp PROPERTY TYPE INTERFACE_LIBRARY)
