# withvs14
cd build
cl ..\src\main.c user32.lib dsound.lib Dxguid.lib xinput.lib -Zi -nologo -I../src
cd ..

