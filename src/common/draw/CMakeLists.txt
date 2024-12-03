option(GOOPAXLIB_DEBUG "GOOPAXLIB_DEBUG" OFF)


find_package(SDL3)
find_package(OpenGL)

if (TARGET SDL3::SDL3)

if (APPLE)
    add_library(goopax_draw window_sdl.cpp window.cpp window_sdl.h window.h window_metal.h window_metal.mm)
else()
    add_library(goopax_draw window_sdl.cpp window.cpp window_sdl.h window.h)
endif()

if (TARGET OpenGL::GL)
    target_link_libraries(goopax_draw PRIVATE OpenGL::GL)
    option(GOOPAX_DRAW_WITH_OPENGL "with OpenGL support" 1)
else()
    option(GOOPAX_DRAW_WITH_OPENGL "with OpenGL support" 0)
endif()
message("OpenGL: ${GOOPAX_DRAW_WITH_OPENGL}")

if (GOOPAX_DRAW_WITH_OPENGL)
    target_compile_definitions(goopax_draw PRIVATE -DWITH_OPENGL=1)
else()
    target_compile_definitions(goopax_draw PRIVATE -DWITH_OPENGL=0)
endif()

if (APPLE)
    option(GOOPAX_DRAW_WITH_METAL "with Metal support" 1)
else()
    option(GOOPAX_DRAW_WITH_METAL "with Metal support" 0)
endif()
message("Metal: ${GOOPAX_DRAW_WITH_METAL}")

if (GOOPAX_DRAW_WITH_METAL)
    target_compile_definitions(goopax_draw PRIVATE -DWITH_METAL=1)
else()
    target_compile_definitions(goopax_draw PRIVATE -DWITH_METAL=0)
endif()

#target_include_directories(goopax_draw SYSTEM PRIVATE "ext/glatter/include")
target_link_libraries(goopax_draw PUBLIC SDL3::SDL3)
if (NOT APPLE)
  if (NOT WIN32)
    target_link_libraries(goopax_draw PUBLIC -lX11)
  endif()
  target_link_libraries(goopax_draw PUBLIC OpenGL::GLU)
endif()
target_link_libraries(goopax_draw PUBLIC goopax::goopax Eigen3::Eigen)

if (GOOPAXLIB_DEBUG)
  target_compile_definitions(goopax_draw PUBLIC -DGOOPAXLIB_DEBUG=1)
else()
  target_compile_definitions(goopax_draw PUBLIC -DGOOPAXLIB_DEBUG=0)
endif()

endif()
