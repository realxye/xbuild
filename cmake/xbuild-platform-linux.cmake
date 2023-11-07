
# Ensure environment has been set
if (NOT RBX_ENV_LINUX)
    message(FATAL_ERROR "Unsupported build environment. Linux target can only be built on Linux")
endif()