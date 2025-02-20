macro(make_persistent A)
foreach(argument ${A})
  string(FIND "${argument}" ":" typepos)
  string(FIND "${argument}" "=" valuepos)
  if (typepos GREATER_EQUAL 1 AND valuepos GREATER_EQUAL 1)
  math(EXPR typepos "${typepos}-2")
  string(SUBSTRING "${argument}" 2 "${typepos}" argname)
  math(EXPR typepos "${typepos}+3")
  math(EXPR valueoffset "${valuepos}-${typepos}")
  string(SUBSTRING "${argument}" "${typepos}" "${valueoffset}" argtype)
  math(EXPR valuepos "${valuepos}+1")
  string(SUBSTRING "${argument}" "${valuepos}" -1 argvalue)
  set("${argname}" "${argvalue}" CACHE "${argtype}" "")
  #message("${argname} is ${argvalue} of type ${argtype}")
  endif()
endforeach()
endmacro()

macro(add_withfile P FN)
  set(T ${ARGV})
  list(REMOVE_AT T 0 1)
  set(missing "")
  foreach(L ${T})
    if (NOT TARGET ${L})
      list(APPEND missing "${L}")
    endif()
  endforeach()
  if ("${missing}" STREQUAL "")
    message("building target ${P}")
    add_executable(${P} ${FN})
    install(TARGETS ${P} DESTINATION bin)
    foreach(L ${T})
      target_link_libraries(${P} ${L})
    endforeach()
    target_link_libraries(${P} goopax::goopax)
    if (UNIX AND NOT APPLE AND NOT CYGWIN AND NOT ANDROID)
      target_link_libraries(${P} -ltbb)
    endif()
    if (IOS)
      set_apple_properties(${P})
    endif()
  else()
    message("not building target ${P} [missing: ${missing}]")
  endif()
endmacro()

macro(add P)
  set(T ${ARGV})
  list(REMOVE_AT T 0)
  add_withfile(${P} ${P}.cpp ${T})
endmacro()
