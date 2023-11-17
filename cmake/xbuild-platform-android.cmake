include_guard(GLOBAL)

# Android target can be built in all dev environment (Windows, MacOS and Linux)
message(STATUS "Target Platform: Android")

# set options
set(XBD_PLATFORM_NAME "Android" CACHE INTERNAL "Target platform name")
set(XBD_PLATFORM_ANDROID ON CACHE BOOL "Target platform is Android" FORCE)
set(XBD_PLATFORM_MOBILE ON CACHE BOOL "Target platform is Mobile" FORCE)

add_compile_definitions(XBD_PLATFORM_ANDROID)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_MOBILE)
