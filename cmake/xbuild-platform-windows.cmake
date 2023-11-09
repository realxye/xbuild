
# Ensure environment has been set
if (NOT XBD_ENV_WINDOWS)
    message(FATAL_ERROR "Unsupported build environment. Windows target can only be built on Windows")
endif()

message(STATUS "Target Platform: Windows")
add_compile_definitions(XBD_PLATFORM_WINDOWS)
add_compile_definitions(XBD_PLATFORM_DESKTOP)