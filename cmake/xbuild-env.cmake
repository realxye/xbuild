include_guard(GLOBAL)

#[[
XBuild support 3 development environment:
    - Windows 64 bits
    - MacOS
    - Linux
]]

if (DEFINED WIN32)
    include(xbuild-env-windows)
else()
    if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        include(xbuild-env-macos)
    else()
        include(xbuild-env-linux)
    endif
endif()
