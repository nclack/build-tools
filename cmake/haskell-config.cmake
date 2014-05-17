#
# Copyright (c) 2014 Nathan Clack, All Rights Reserved
#
#
# ghc_add_executable(name source [source...]
#                    [OPTIONS options ]
# )
include(CMakeParseArguments)

set(GHC ghc)

function(ghc_add_executable tgt)
  cmake_parse_arguments(GHC "" "" "OPTIONS" ${ARGV})

  set(srcs ${GHC_UNPARSED_ARGUMENTS})
  list(REMOVE_AT srcs 0)

  add_custom_target(${tgt} ALL
      COMMAND ${GHC}
              -odir    ${CMAKE_CURRENT_BINARY_DIR}/ghc/obj
              -stubdir ${CMAKE_CURRENT_BINARY_DIR}/ghc/stub
              -hidir   ${CMAKE_CURRENT_BINARY_DIR}/ghc/hi
              ${GHC_OPTIONS}
              -o ${CMAKE_CURRENT_BINARY_DIR}/${tgt}
              ${CMAKE_CURRENT_SOURCE_DIR}/${srcs}
      DEPENDS ${srcs}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "GHC: Building ${tgt}."
      SOURCES ${srcs}
    )
endfunction()
