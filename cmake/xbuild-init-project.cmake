include_guard(GLOBAL)

# Set path
list(APPEND CMAKE_MODULE_PATH "${XBUILD_PRELUDE_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${XBUILD_PRELUDE_PACKAGES_DIR}")

# Include build related scripts
include(xbuild-env)
include(xbuild-platform)
include(xbuild-compiler)
include(xbuild-util-cmake)