#include "app.h"

int CALLBACK WinMain(
  HINSTANCE hInstance,
  HINSTANCE hPrevInstance,
  LPSTR lpCmdLine,
  int nCmdShow)
{
    platform p;
    p.init();
    p.show();
    p.mainloop();
  
    return 0;
}
