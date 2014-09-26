set(RPATH \$ORIGIN)
if(APPLE)
  set(RPATH @rpath)
endif()
set(CMAKE_INSTALL_RPATH ${RPATH})

