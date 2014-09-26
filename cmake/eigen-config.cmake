#
# Eigen 
#

include(ExternalProject)
include(FindPackageHandleStandardArgs)

set(EIGEN_URL http://bitbucket.org/eigen/eigen/get/3.1.3.tar.gz)

if(NOT TARGET eigen)
  ExternalProject_Add(eigen
    URL     ${EIGEN_URL} #http://dl.dropbox.com/u/782372/Software/eigen-eigen-43d9075b23ef.tar.gz
    URL_MD5 dc4247efd4f5d796041f999e8774af04
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
               -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  )
endif()
get_target_property(EIGEN_ROOT_DIR eigen _EP_INSTALL_DIR)

set(EIGEN_INCLUDE_DIR  ${EIGEN_ROOT_DIR}/include/eigen3)
set(EIGEN_INCLUDE_DIRS ${EIGEN_INCLUDE_DIR})

find_package_handle_standard_args(EIGEN DEFAULT_MSG
  EIGEN_INCLUDE_DIR
)

set_target_properties(eigen PROPERTIES FOLDER ExternalProjects)