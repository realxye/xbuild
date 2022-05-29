if(NOT XBUILD_PLATFORM_ANDROID)
    message(FATAL_ERROR "xbuild-platform-android: XBUILD_PLATFORM_ANDROID is not set")
endif()

# Set common data
set(XBUILD_PLATFORM_STRING "Android")
set(XBUILD_PLATFORM_MOBILE ON)
set(XBUILD_PLATFORM_ARCH "arm")
