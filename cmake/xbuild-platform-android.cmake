
# Android target can be built in all dev environment (Windows, MacOS and Linux)

message(STATUS "Target Platform: Android")
add_compile_definitions(XBD_PLATFORM_ANDROID)
add_compile_definitions(XBD_PLATFORM_MOBILE)