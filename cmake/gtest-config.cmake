include(ExternalProject)
include(FindPackageHandleStandardArgs)

if(NOT GTEST_INCLUDE_DIR) #if this is set, assume gtest location has been overridden in parent
  if(NOT TARGET gtest)
    # DOWNLOAD AND BUILD
    ExternalProject_Add(gtest
      SVN_REPOSITORY http://googletest.googlecode.com/svn/trunk/
      UPDATE_COMMAND ""
      INSTALL_COMMAND "" #The gtest project  doesn't support install
      CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                 -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                 -DBUILD_SHARED_LIBS:BOOL=TRUE
      )
  endif()
  ExternalProject_Get_Property(gtest BINARY_DIR)
  ExternalProject_Get_Property(gtest SOURCE_DIR)

  file(GLOB HDRS *.h ${SOURCE_DIR}/include/gtest)

  if(NOT TARGET libgtest)
    add_library(libgtest IMPORTED SHARED)
    add_library(libgtest-main IMPORTED SHARED)
  endif()

  set_target_properties(libgtest PROPERTIES  
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX
    IMPORTED_IMPLIB   ${BINARY_DIR}/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}
    IMPORTED_LOCATION ${BINARY_DIR}/${CMAKE_CFG_INTDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}gtest${CMAKE_SHARED_LIBRARY_SUFFIX}
    PUBLIC_HEADER     "${HDRS}"
  )
  set_target_properties(libgtest-main PROPERTIES  
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX
    IMPORTED_IMPLIB   ${BINARY_DIR}/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gtest_main${CMAKE_STATIC_LIBRARY_SUFFIX}
    IMPORTED_LOCATION ${BINARY_DIR}/${CMAKE_CFG_INTDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}gtest_main${CMAKE_SHARED_LIBRARY_SUFFIX}
    PUBLIC_HEADER     "${HDRS}"
  )

  get_property(GTEST_LIBRARY      TARGET libgtest      PROPERTY LOCATION)
  get_property(GTEST_MAIN_LIBRARY TARGET libgtest-main PROPERTY LOCATION)
  set(GTEST_SHARED_LIBRARIES ${GTEST_LIBRARY} ${GTEST_MAIN_LIBRARY})
  if(WIN32)
    get_property(GTEST_LIBRARY      TARGET libgtest      PROPERTY IMPORTED_IMPLIB)
    get_property(GTEST_MAIN_LIBRARY TARGET libgtest-main PROPERTY IMPORTED_IMPLIB)
  endif()
  set(GTEST_BOTH_LIBRARIES ${GTEST_LIBRARY} ${GTEST_MAIN_LIBRARY})
  set(GTEST_INCLUDE_DIR ${SOURCE_DIR}/include)



  ### INSTALL
  if(NOT TARGET install-gtest)
    add_custom_target(install-gtest DEPENDS ${GTEST_SHARED_LIBRARIES})
  endif()
  foreach(lib libgtest libgtest-main)
    get_target_property(loc ${lib} LOCATION)  
    if(MSVC)
      string(REPLACE ${CMAKE_CFG_INTDIR} Debug   loc_debug   ${loc})
      string(REPLACE ${CMAKE_CFG_INTDIR} Release loc_release ${loc})
    else()
      set(loc_debug   ${loc})
      set(loc_release ${loc})
    endif()
    #install(FILES ${loc_release} DESTINATION bin CONFIGURATIONS)
    install(FILES ${loc_debug}   DESTINATION bin CONFIGURATIONS Debug)
    install(FILES ${loc_release} DESTINATION bin CONFIGURATIONS Release)
  endforeach()
endif()

find_package_handle_standard_args(GTEST DEFAULT_MSG
  GTEST_BOTH_LIBRARIES
  GTEST_INCLUDE_DIR
)

macro(gtest_copy_shared_libraries _target)  
  foreach(_lib ${GTEST_SHARED_LIBRARIES})
    add_custom_command(TARGET ${_target} POST_BUILD
      COMMAND ${CMAKE_COMMAND};-E;copy;${_lib};$<TARGET_FILE_DIR:${_target}>)  
  endforeach()
endmacro()
