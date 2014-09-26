include(ExternalProject)
include(FindPackageHandleStandardArgs)

set(SDL2_TTF_USE_SHARED FALSE)
set(SDL_TTF_LIB_DIR) # - used to find shared libs to copy to target
if(MSVC)
  set(url http://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-devel-2.0.12-VC.zip)
  if(NOT TARGET libsdl2-ttf)
    ExternalProject_Add(libsdl2-ttf URL ${url} TIMEOUT 10 CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND "")
    set_target_properties(libsdl2-ttf PROPERTIES FOLDER ExternalProjects)
  endif()
  ExternalProject_Get_Property(libsdl2-ttf SOURCE_DIR)
  set(sub x86)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(sub x64)
  endif()
  set(SDL_TTF_LIB_DIR      ${SOURCE_DIR}/lib/${sub})

  if(NOT TARGET sdl2-ttf)
    add_library(sdl2-ttf STATIC IMPORTED)
    add_dependencies(sdl2-ttf libsdl2-ttf)
    set_target_properties(sdl2-ttf PROPERTIES IMPORTED_LOCATION ${SDL_TTF_LIB_DIR}/SDL2_ttf.lib)
  endif()

  set(SDL_TTF_INCLUDE_DIRS ${SOURCE_DIR}/include)
  set(SDL_TTF_LIBRARY      sdl2-ttf)
  set(SDL2_TTF_USE_SHARED  TRUE)
  set(SDL_TTF_LIBRARIES ${SDL_TTF_LIBRARY})
elseif(APPLE)
  find_library(SDL_TTF_LIBRARY SDL2_ttf)
  set(SDL_TTF_INCLUDE_DIRS ${SDL_TTF_LIBRARY}/Headers)
  set(SDL_TTF_LIBRARIES ${SDL_TTF_LIBRARY})
endif()

## TARGET_ADD_SDL_TTF
# Usage: target_add_sdl_ttf(target [INSTALL])
# 
# If INSTALL is found, then any required shared libraries will be installed
# alongside the target.
function(target_add_sdl_ttf tgt)
  set(opts ${ARGN})
  
  # basic configuration
  target_include_directories(${tgt} PRIVATE ${SDL_TTF_INCLUDE_DIRS})
  target_link_libraries(${tgt} ${SDL_TTF_LIBRARIES})

  if(SDL2_TTF_USE_SHARED)
    file(GLOB libs ${SDL_TTF_LIB_DIR}/*${CMAKE_SHARED_LIBRARY_SUFFIX})    
    foreach(lib ${libs})
      add_custom_command(TARGET ${tgt} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${lib}"
                $<TARGET_FILE_DIR:${tgt}>
        DEPENDS libsdl2-ttf)
    endforeach()

    list(FIND opts INSTALL should_install)
    if(${should_install} GREATER -1)
      message(STATUS "Will install sdl2-ttf for ${tgt}")
      install(FILES ${libs} DESTINATION ${tgt})
    endif()
  endif()
endfunction()

## FPHSA
find_package_handle_standard_args(SDL_TTF DEFAULT_MSG
  SDL_TTF_INCLUDE_DIRS
  SDL_TTF_LIBRARY)
