
# Ensure environment has been set
if (NOT XBD_ENV_LINUX)
    message(FATAL_ERROR "Unsupported build environment. Linux target can only be built on Linux")
endif()

message(STATUS "Target Platform: Linux")

# set options
set(XBD_PLATFORM_NAME "Linux")
set(XBD_PLATFORM_LINUX ON)
set(XBD_PLATFORM_DESKTOP ON)

add_compile_definitions(XBD_PLATFORM_LINUX)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_DESKTOP)
