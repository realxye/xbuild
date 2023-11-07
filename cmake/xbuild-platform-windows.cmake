
# Ensure environment has been set
if (NOT RBX_ENV_WINDOWS)
    message(FATAL_ERROR "Unsupported build environment. Windows target can only be built on Windows")
endif()