#include "precompile.h"
#include "common/util.h"
#include "common/version.h"

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nShowCmd)
{
    uint32_t ver = xbuild::GetSampleVersion();
    wchar_t msg[1024] = {};
    swprintf_s(msg, L"XBUILD Samples\nver %d.%d", ver >> 16, ver & 0xFFFF);
    MessageBoxW(NULL, msg, L"xbuild", MB_OK);
    return 0;
}