#include "app.h"
#include "game.h"
#include <strsafe.h>

void update(platform* p,state& s,double dt) {
    RECT rc;
    wchar_t buf[1024]={0};
    GetClientRect(p->h,&rc);
    D2D1_RECT_F rect=D2D1::RectF(rc.left,rc.top,rc.right-rc.left,rc.bottom-rc.top);
    StringCbPrintfW(buf,sizeof(buf),L"doing it %f ms",1e3* p->toc(s.clocks));
    p->rendertarget->DrawText(buf,wcslen(buf),p->textformat,rect,p->brush);
}
/*

It's better if this is just manipulating data that the app uses to draw.
For example, if it just sets the text.

Any function calls to the platform require some linking.
    Just pass them in as pointers...for c++ means they have to be virtual
hand*/