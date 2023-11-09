
# Ensure environment has been set
if (NOT RBX_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. iOS target can only be built on Mac")
endif()

message(STATUS "Target Platform: iOS")
add_compile_definitions(XBD_PLATFORM_IOS)
add_compile_definitions(XBD_PLATFORM_MOBILE)