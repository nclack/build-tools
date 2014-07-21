include(ExternalProject)
include(FindPackageHandleStandardArgs)

set(SDL2_IMAGE_USE_SHARED FALSE)
set(SDL_IMAGE_LIB_DIR) # - used to find shared libs to copy to target
if(MSVC)
  set(url http://www.libsdl.org/projects/SDL_image/release/SDL2_image-devel-2.0.0-VC.zip)
  if(NOT TARGET libsdl2-image)
    ExternalProject_Add(libsdl2-image URL ${url} CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND "")
    set_target_properties(libsdl2-image PROPERTIES FOLDER ExternalProjects)
  endif()
  ExternalProject_Get_Property(libsdl2-image SOURCE_DIR)
  set(sub x86)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(sub x64)
  endif()
  set(SDL_IMAGE_LIB_DIR      ${SOURCE_DIR}/lib/${sub})

  if(NOT TARGET sdl2-image)
    add_library(sdl2-image MODULE IMPORTED)
    add_dependencies(sdl2-image libsdl2-image)
    set_target_properties(sdl2-image PROPERTIES IMPORTED_LOCATION ${SDL_IMAGE_LIB_DIR}/SDL2_image.lib)
  endif()

  set(SDL_IMAGE_INCLUDE_DIRS ${SOURCE_DIR}/include)
  set(SDL_IMAGE_LIBRARY      sdl2-image)
  set(SDL2_IMAGE_USE_SHARED  TRUE)
elseif(APPLE)
  find_library(SDL_IMAGE_LIBRARY SDL2_image)
  set(SDL_IMAGE_INCLUDE_DIRS ${SDL_IMAGE_LIBRARY}/Headers)
  set(SDL_IMAGE_LIBRARIES ${SDL_IMAGE_LIBRARY})
endif()

## Utility: Copy DLL to target
function(copy_sdl_image_to_target tgt)
  set(opts ${ARGN})
  if(SDL2_IMAGE_USE_SHARED)
    file(GLOB libs ${SDL_IMAGE_LIB_DIR}/*${CMAKE_SHARED_LIBRARY_SUFFIX})
    foreach(lib ${libs})
      add_custom_command(TARGET ${tgt} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${lib}"
          $<TARGET_FILE_DIR:${tgt}>
      DEPENDS libsdl2-image)
    endforeach()

    list(FIND opts INSTALL should_install)
    if(${should_install} GREATER -1)
      message(STATUS "Will install sdl2-image for ${tgt}")
      install(FILES ${libs} DESTINATION ${tgt})
    endif()
  endif()
endfunction()

## FPHSA
find_package_handle_standard_args(SDL_IMAGE DEFAULT_MSG
  SDL_IMAGE_INCLUDE_DIRS
  SDL_IMAGE_LIBRARY)
