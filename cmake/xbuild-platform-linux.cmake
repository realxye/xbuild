include_guard(GLOBAL)

# Ensure environment has been set
if (NOT XBD_ENV_LINUX)
    message(FATAL_ERROR "Unsupported build environment. Linux target can only be built on Linux")
endif()

message(STATUS "Target Platform: Linux")

# set options
set(XBD_PLATFORM_NAME "Linux" CACHE INTERNAL "Target platform name")
set(XBD_PLATFORM_LINUX ON CACHE BOOL "Target platform is Linux" FORCE)
set(XBD_PLATFORM_DESKTOP ON CACHE BOOL "Target platform is Desktop" FORCE)

add_compile_definitions(XBD_PLATFORM_LINUX)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_DESKTOP)
