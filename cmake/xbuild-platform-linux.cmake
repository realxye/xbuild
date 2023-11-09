
# Ensure environment has been set
if (NOT RBX_ENV_LINUX)
    message(FATAL_ERROR "Unsupported build environment. Linux target can only be built on Linux")
endif()

message(STATUS "Target Platform: Linux")
add_compile_definitions(XBD_PLATFORM_LINUX)
add_compile_definitions(XBD_PLATFORM_DESKTOP)