#include "precompile.h"

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    switch( fdwReason ) 
    { 
        case DLL_PROCESS_ATTACH:
            break;

        case DLL_THREAD_ATTACH:
            break;

        case DLL_THREAD_DETACH:
            break;

        case DLL_PROCESS_DETACH:
            break;
    }
    return TRUE;
}

DWORD WINAPI GetSampleVersion()
{
    return 0x00010000;
}
