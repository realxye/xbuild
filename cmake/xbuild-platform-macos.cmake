
# Ensure environment has been set
if (NOT RBX_ENV_MACOS)
    message(FATAL_ERROR "Unsupported build environment. Mac target can only be built on Mac")
endif()