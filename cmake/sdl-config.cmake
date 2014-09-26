include(ExternalProject)
include(FindPackageHandleStandardArgs)

## External Project
if(MSVC)
  set(url http://www.libsdl.org/release/SDL2-devel-2.0.3-VC.zip)
  if(NOT TARGET libsdl2)
    ExternalProject_Add(libsdl2 URL ${url} CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND "")
    set_target_properties(libsdl2 PROPERTIES FOLDER ExternalProjects)
  endif()
  ExternalProject_Get_Property(libsdl2 SOURCE_DIR)
  set(sub x86)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(sub x64)
  endif()
  set(incdir ${SOURCE_DIR}/include)
  set(libdir ${SOURCE_DIR}/lib/${sub})
  set(SDL_PREFIX ${SOURCE_DIR})
  set(SDL_USE_SHARED TRUE)

  if(NOT TARGET sdl2)
    add_library(sdl2     STATIC IMPORTED)
    add_library(sdl2main STATIC IMPORTED)
    add_dependencies(sdl2     libsdl2)
    add_dependencies(sdl2main libsdl2)
    set_target_properties(sdl2     PROPERTIES IMPORTED_LOCATION ${libdir}/SDL2.lib)
    set_target_properties(sdl2main PROPERTIES IMPORTED_LOCATION ${libdir}/SDL2main.lib)
  endif()

  set(SDL_INCLUDE_DIRS ${SOURCE_DIR}/include)
  set(SDL_LIBRARY   sdl2)
  set(SDL_LIBRARIES sdl2 sdl2main ${extras})
elseif(APPLE)
  find_library(SDL_LIBRARY SDL2)
  set(SDL_INCLUDE_DIRS ${SDL_LIBRARY}/Headers)
  set(SDL_LIBRARIES ${SDL_LIBRARY})
endif()

## TARGET_ADD_SDL
# Usage: target_add_sdl(target [INSTALL])
# 
# If INSTALL is found, then any required shared libraries will be installed
# alongside the target.
function(target_add_sdl tgt)
  set(opts ${ARGN})
  
  # basic configuration
  target_include_directories(${tgt} PRIVATE ${SDL_INCLUDE_DIRS})
  target_link_libraries(${tgt} ${SDL_LIBRARIES})

  # sdl -- copy shared libraries to target
  if(SDL_USE_SHARED)
    ExternalProject_Get_Property(libsdl2 SOURCE_DIR)
    set(sub x86)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(sub x64)
    endif()
    add_custom_command(TARGET ${tgt} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${SOURCE_DIR}/lib/${sub}/SDL2.dll"      # <--this is in-file
            $<TARGET_FILE_DIR:${tgt}>
        DEPENDS libsdl2)

    list(FIND opts INSTALL should_install)
    if(${should_install} GREATER -1)
      message(STATUS "Will install sdl2 for ${tgt}")
      file(GLOB dlls ${SOURCE_DIR}/lib/${sub}/*${CMAKE_SHARED_LIBRARY_SUFFIX})
      install(FILES ${dlls} DESTINATION ${tgt})
    endif()
  endif()
endfunction()

## FPHSA
find_package_handle_standard_args(SDL DEFAULT_MSG
  SDL_INCLUDE_DIRS
  SDL_LIBRARY)

