add_definitions(/FS)
add_executable(scratch WIN32 
    main.cpp
    app.h
    app.cpp
)
target_link_libraries(scratch d2d1.lib dwrite.lib)
add_library(game MODULE game.h game.cpp)