if(NOT XBUILD_PLATFORM_IOS)
    message(FATAL_ERROR "xbuild-platform-ios: XBUILD_PLATFORM_IOS is not set")
endif()

# Set common data
set(XBUILD_PLATFORM_STRING "iOS")
set(XBUILD_PLATFORM_MOBILE ON)
set(XBUILD_PLATFORM_ARCH "arm64")

set(CMAKE_CONFIGURATION_TYPES "Debug;Optimized;Release" CACHE STRING "" FORCE)
