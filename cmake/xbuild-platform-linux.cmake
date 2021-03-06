if(NOT XBUILD_PLATFORM_LINUX)
    message(FATAL_ERROR "xbuild-platform-linux: XBUILD_PLATFORM_LINUX is not set")
endif()

# Set common data
set(XBUILD_PLATFORM_STRING "Linux")
set(XBUILD_PLATFORM_DESKTOP ON)
if(XBUILD_PLATFORM_BITS64)
    set(XBUILD_PLATFORM_ARCH "x86_64")
else()
    set(XBUILD_PLATFORM_ARCH "x86")
endif()
