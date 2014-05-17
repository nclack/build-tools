#
# Copyright (c) 2014 Nathan Clack, All Rights Reserved
#

macro(show v)
  message("${v} is ${${v}}")
endmacro()

macro(showeach vs)
  message("${vs} is")
  foreach(v ${${vs}})
    message("   ${v}")
    endforeach()
endmacro()
