# TRE - a fuzzy regular expression library
#
# Configured as an external project.
#

include(ExternalProject)
include(FindPackageHandleStandardArgs)

set(TRE_GIT_REPOSITORY https://github.com/nclack/tre.git CACHE STRING "Location of the git repository for tre.")
if(NOT TARGET tre)
  ExternalProject_Add(tre
    GIT_REPOSITORY ${TRE_GIT_REPOSITORY}
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    )
endif()
ExternalProject_Get_Property(tre INSTALL_DIR)

add_library(libtre STATIC IMPORTED)
set_target_properties(libtre PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_LOCATION "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tre${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(libtre tre)

### exit variables
set(TRE_INCLUDE_DIR "${INSTALL_DIR}/include")
set(TRE_LIBRARY libtre)
set(TRE_INCLUDE_DIRS ${TRE_INCLUDE_DIR})
set(TRE_LIBRARIES ${TRE_LIBRARY})

find_package_handle_standard_args(TRE DEFAULT_MSG TRE_INCLUDE_DIR TRE_LIBRARY)


## target_add_tre
# Usage: target_add_tre(target)
function(target_add_tre tgt)
  target_include_directories(${tgt} PRIVATE ${TRE_INCLUDE_DIRS})
  target_link_libraries(${tgt} ${TRE_LIBRARIES})
endfunction()