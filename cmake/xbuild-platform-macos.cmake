
# Ensure environment has been set
if (NOT XBD_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. Mac target can only be built on Mac")
endif()

message(STATUS "Target Platform: MacOS")
add_compile_definitions(XBD_PLATFORM_MACOS)
add_compile_definitions(XBD_PLATFORM_DESKTOP)