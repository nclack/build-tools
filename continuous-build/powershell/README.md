# Instructions

The way I usually run these is I will copy them to the root development folder,
open a console, and run 

    ./continuous.ps1

This will start watching a directory called "src" located in the same directory
(so [dev-root]/src).  It will take control of the current console, using it 
for output etc, and will continue running until that console is closed.

Every time a change in the contents of "src" is detected, it calls "build.ps1",
which is responsible for rebuilding everything.  You will need to change it for
your application.

"build-init.ps1" is called once by "continuous.ps1" at startup.  This should be
used to initialize the build directory, etc... to prepare things for "build.ps1"

