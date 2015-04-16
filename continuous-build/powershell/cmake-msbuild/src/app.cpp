#include "app.h"
#include <strsafe.h>


#define ERR(e) do{if(!(e)) {onerr(#e,__FILE__,__LINE__,__FUNCTION__); goto Error;}}while(0)
static void onerr(const char* expr,const char*file,int line,const char* function){
    int ecode=GetLastError();
    char emsg[1024]={0},
        str[1024]={0};
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
                  0, /* source */
                  ecode, /* id */
                  MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT), /* lang id */
                  emsg,
                  sizeof(emsg),
                  0);
    StringCbPrintf(str,sizeof(str)
                   ,"%s(%d) - %s()\n\tExpression evaluated to false\n\t%s\n\t%s\n"
                   ,file,line,function,expr,emsg);

    OutputDebugString(str);
    MessageBox(0,str,"Error",MB_OK);
    PostQuitMessage(1);
}

struct game
{
    const char * filename;
    char filename_full_path_[1024];
    HMODULE h;
    double updatetimer;
    FILETIME last_creation_filetime_;


    void(*update_)(platform*,state&,double);

    game(const char * filename=0) 
        : filename(filename)
        , updatetimer(0.0)
        , h(0)
    {
        WIN32_FILE_ATTRIBUTE_DATA info;
        
        char *exepath;
        _get_pgmptr(&exepath);
        ZeroMemory(filename_full_path_,sizeof(filename_full_path_));
        StringCbCopyA((char*)filename_full_path_,sizeof(filename_full_path_),exepath);
        *(strrchr(filename_full_path_,'\\')+1)=0;
        StringCbCatA(filename_full_path_,sizeof(filename_full_path_),filename);

        ERR(GetFileAttributesExA(filename_full_path_,GetFileExInfoStandard,&info));
        last_creation_filetime_=info.ftLastWriteTime;
    Error:
        load();
    }
    void load()
    {
        h=LoadLibraryA("game.dll");
        update_=(void(*)(platform*,state&,double))GetProcAddress(h,"update");
    }

    void maybe_reload()
    {
        WIN32_FILE_ATTRIBUTE_DATA info;
        if(GetFileAttributesExA(filename_full_path_,GetFileExInfoStandard,&info)){
            auto time=info.ftLastWriteTime;
            if(!CompareFileTime(&last_creation_filetime_,&time))
                return;
            last_creation_filetime_=time;
            FreeLibrary(h);
            load();
        }
    }

    void update(platform* p,state& s,double dt){
        updatetimer+=dt;
        if(updatetimer>0.3) {
            maybe_reload();
            updatetimer=0.0;
        }
        if(update_) update_(p,s,dt);
    }
};

static HWND window(){
    WNDCLASSEX c={0};
    c.cbSize=sizeof(c);
    c.style=CS_HREDRAW|CS_VREDRAW;
    c.hInstance=GetModuleHandle(0);
    c.lpszClassName="ScratchClass";
    c.hIcon=LoadIcon(0,IDI_APPLICATION);
    c.hCursor=LoadCursor(0,IDC_ARROW);
    c.hIconSm=LoadIcon(0,IDI_APPLICATION);
    c.lpfnWndProc=[](HWND h,UINT msg,WPARAM wparam,LPARAM lparam)->LPARAM{
        platform *p=(platform*)GetWindowLongPtr(h,GWLP_USERDATA);
        switch(msg){
            case WM_SIZE:
                if(p->rendertarget)
                    p->rendertarget->Resize(D2D1::SizeU(LOWORD(lparam),HIWORD(lparam)));
                break;
            case WM_DESTROY:
                PostQuitMessage(0);
                break;
            default:
                return DefWindowProc(h,msg,wparam,lparam);
        }
        return 0;
    };
    RegisterClassEx(&c);
    HWND h=CreateWindow("ScratchClass","Scratch",
                        WS_OVERLAPPEDWINDOW,
                        CW_USEDEFAULT,CW_USEDEFAULT,
                        CW_USEDEFAULT,CW_USEDEFAULT,
                        0,0,GetModuleHandle(0),0);
    return h;
}

platform::platform():rendertarget(0){}

void platform::init(){
    h=window();
    SetWindowLongPtr(h,GWLP_USERDATA,(LONG_PTR)this);
    /* Direct2d */
    D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED,&d2d);

    {
        RECT rc;
        GetClientRect(h,&rc);
        D2D1_SIZE_U size=D2D1::SizeU(rc.right-rc.left,rc.bottom-rc.top);
        d2d->CreateHwndRenderTarget(D2D1::RenderTargetProperties(),
                                    D2D1::HwndRenderTargetProperties(h,size),
                                    &rendertarget);
    }

    rendertarget->CreateSolidColorBrush(D2D1::ColorF(D2D1::ColorF::PaleGoldenrod),&brush);

    /* direct write */
    DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED,__uuidof(IDWriteFactory),(IUnknown**)&directwrite);

    directwrite->CreateTextFormat(L"Anonymous Pro",0,
                                  DWRITE_FONT_WEIGHT_REGULAR,
                                  DWRITE_FONT_STYLE_NORMAL,
                                  DWRITE_FONT_STRETCH_NORMAL,
                                  72.0f,L"en-us",&textformat);
    textformat->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
    textformat->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
}

void platform::show(){
    ShowWindow(h,SW_SHOW);
}

void platform::mainloop(){
    state s;
    game g("game.dll");
    toc(s.clocks);
    LARGE_INTEGER loop_timer;
    QueryPerformanceCounter(&loop_timer);
    while(1){
        MSG msg;
        if(PeekMessage(&msg,0,0,0,PM_REMOVE)){
            TranslateMessage(&msg);
            DispatchMessage(&msg);
            if(msg.message==WM_QUIT)
                break;
        }                       
        rendertarget->BeginDraw();
        rendertarget->SetTransform(D2D1::IdentityMatrix());
        rendertarget->Clear(D2D1::ColorF(D2D1::ColorF::DarkGreen));
        g.update(this,s,toc(&loop_timer));
        QueryPerformanceCounter(s.clocks+1);
        rendertarget->EndDraw();            
        s.time+=toc(s.clocks+1);
        s.count+=1;
    }
    {
        wchar_t buf[1024]={0};
        StringCbPrintfW(buf,sizeof(buf),L"Rendered in %f us (average)\n",1e6*s.time/s.count);
        OutputDebugStringW(buf);
    }
}

double platform::toc(clock_t * clock){
    LARGE_INTEGER cur,freq,ns;
    QueryPerformanceCounter(&cur);
    QueryPerformanceFrequency(&freq);
    ns.QuadPart=cur.QuadPart-clock->QuadPart;
    ns.QuadPart*=1000000000LL;
    ns.QuadPart/=freq.QuadPart;
    QueryPerformanceCounter(clock);
    return 1e-9*ns.QuadPart;
}

