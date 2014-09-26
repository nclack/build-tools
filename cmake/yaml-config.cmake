#
# YAML
#

include(ExternalProject)
include(FindPackageHandleStandardArgs)

macro(show v)
  message("${v} is ${${v}}")
endmacro()

set(YAML_URL http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz CACHE STRING "Location of the YAML source code download.")
set(YAML_MD5 36c852831d02cf90508c29852361d01b CACHE STRING "MD5 checksum of the yaml source code archive.")
if(MSVC)
  # Notes:
  # - not sure what the proper cmake var for msbuild is, but I don't really care.  Fix one day!
  # - not sure how to /p:Configuration=Debug
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_PLAT x64)
  else()
    set(_PLAT Win32)
  endif()
  set( _PATCH_FILE "${PROJECT_BINARY_DIR}/cmake/yaml-patch.cmake" )
  set( _SOURCE_DIR "${PROJECT_BINARY_DIR}/yaml-prefix/src/yaml/win32/vs2008" ) # Assumes default prefix path
  configure_file(  "${PROJECT_SOURCE_DIR}/cmake/yaml-patch.cmake.in" "${_PATCH_FILE}" @ONLY )
  ExternalProject_Add(yaml
    URL ${YAML_URL}
    URL_MD5 ${YAML_MD5}
    PATCH_COMMAND "${CMAKE_COMMAND};-P;${_PATCH_FILE}" 
    CONFIGURE_COMMAND devenv;/upgrade;<SOURCE_DIR>/win32/vs2008/libyaml.sln
    BUILD_COMMAND msbuild;/target:yaml;<SOURCE_DIR>/win32/vs2008/libyaml.sln;/p:Platform=${_PLAT}
    INSTALL_COMMAND ""
    BUILD_IN_SOURCE TRUE
  )
  get_target_property(YAML_SRC_DIR yaml _EP_SOURCE_DIR)
  set(YAML_ROOT_DIR ${YAML_SRC_DIR}/win32/vs2008/Output/$(Configuration))
  set(YAML_INCLUDE_DIR ${YAML_SRC_DIR}/include CACHE PATH "Path to yaml.h")
else()
  ExternalProject_Add(yaml
    URL ${YAML_URL}
    URL_MD5 ${YAML_MD5}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure;--prefix=<INSTALL_DIR>;--with-pic
    )
  get_target_property(YAML_ROOT_DIR yaml _EP_INSTALL_DIR)
  set(YAML_INCLUDE_DIR ${YAML_ROOT_DIR}/include CACHE PATH "Path to yaml.h")
endif()




add_library(libyaml STATIC IMPORTED)
set_target_properties(libyaml PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_LOCATION                "${YAML_ROOT_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml${CMAKE_STATIC_LIBRARY_SUFFIX}"
  IMPORTED_LOCATION_DEBUG          "${YAML_ROOT_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml${CMAKE_STATIC_LIBRARY_SUFFIX}"
  IMPORTED_LOCATION_RELEASE        "${YAML_ROOT_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml${CMAKE_STATIC_LIBRARY_SUFFIX}"
  IMPORTED_LOCATION_MINSIZEREL     "${YAML_ROOT_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml${CMAKE_STATIC_LIBRARY_SUFFIX}"
  IMPORTED_LOCATION_RELWITHDEBINFO "${YAML_ROOT_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml${CMAKE_STATIC_LIBRARY_SUFFIX}"
  )
add_dependencies(libyaml yaml)

set(YAML_INCLUDE_DIRS ${YAML_INCLUDE_DIR})
SET(YAML_LIBRARY libyaml)
set(YAML_LIBRARIES ${YAML_LIBRARY})

find_package_handle_standard_args(YAML DEFAULT_MSG
  YAML_LIBRARY
  YAML_INCLUDE_DIR
)
