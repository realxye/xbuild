
# Android target can be built in all dev environment (Windows, MacOS and Linux)

message(STATUS "Target Platform: Android")

# set options
set(XBD_PLATFORM_NAME "Android")
set(XBD_PLATFORM_MOBILE ON)

add_compile_definitions(XBD_PLATFORM_ANDROID)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_MOBILE)
