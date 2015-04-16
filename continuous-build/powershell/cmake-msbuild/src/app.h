#pragma once
#include <windows.h>
#include <d2d1.h>
#include <dwrite.h>
#include <functional>

#define countof(e) (sizeof(e)/sizeof(*(e)))

typedef LARGE_INTEGER clock_t;

struct state{
    clock_t clocks[2];
    double time=0.0,count=0.0;
};

struct platform {
    HWND h;
    ID2D1Factory *d2d;
    ID2D1HwndRenderTarget *rendertarget;
    ID2D1SolidColorBrush *brush;
    IDWriteFactory *directwrite;
    IDWriteTextFormat *textformat;


    platform();
    void init();
    void show();
    void mainloop();

    virtual double toc(clock_t *clock);
};

