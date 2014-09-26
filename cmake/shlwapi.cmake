### Windows shell lightweight utility functions
if(WIN32)
find_library(SHLWAPI Shlwapi.lib) 
else()
set(SHLWAPI)
endif()