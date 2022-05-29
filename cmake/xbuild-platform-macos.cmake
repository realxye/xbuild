if(NOT XBUILD_PLATFORM_MACOS)
    message(FATAL_ERROR "xbuild-platform-macos: XBUILD_PLATFORM_MACOS is not set")
endif()

# Set common data
set(XBUILD_PLATFORM_STRING "MacOS")
set(XBUILD_PLATFORM_DESKTOP ON)
set(XBUILD_PLATFORM_ARCH "x86_64")
