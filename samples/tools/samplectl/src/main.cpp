#include <cstdint>
#include <string>
#include <stdio.h>
#include "common/util.h"
#include "common/version.h"

int main(int argc, char** argv)
{
    const uint32_t ver = xbuild::GetSampleVersion();

    if (argc < 2)
    {
        printf_s("XBUILD Samples\nver %d.%d\n", ver >> 16, ver & 0xFFFF);
        return 0;
    }
    
    if (0 == _stricmp(argv[1], "--help") || (2 == strlen(argv[1]) && (argv[1][0]=='-' || argv[1][0]=='/') && (argv[1][1]=='h' || argv[1][1]=='?')))
    {
        printf_s("XBUILD Samples (ver %d.%d)\n", ver >> 16, ver & 0xFFFF);
        printf_s("Usage:\n");
        printf_s("    samplectl.exe [--help] [--version] [--driver]\n");
    }
    else if (0 == _stricmp(argv[1], "--version") || (2 == strlen(argv[1]) && (argv[1][0]=='-' || argv[1][0]=='/') && argv[1][1]=='v'))
    {
        printf_s("XBUILD Samples (ver %d.%d)\n", ver >> 16, ver & 0xFFFF);
    }
    else if (0 == _stricmp(argv[1], "--driver") || (2 == strlen(argv[1]) && (argv[1][0]=='-' || argv[1][0]=='/') && argv[1][1]=='v'))
    {
        printf_s("XBUILD Samples (ver %d.%d)\n", ver >> 16, ver & 0xFFFF);
        printf_s("    Sample Driver Status: %d\n", xbuild::CheckSampleDrv());
    }
    else
    {
        printf_s("Unknown command: %s\n", argv[1]);
    }

    return 0;
}