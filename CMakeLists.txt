cmake_minimum_required(VERSION 3.26.5)
include(CMakeDependentOption)
include(CMakePrintHelpers)
include(FeatureSummary)

# 🚨 NEVER EVER EVER EVER. CALL `project()` IN THIS CMakeLists.txt file!! 🚨
set(CMAKE_DISABLE_IN_SOURCE_BUILD YES CACHE BOOL "Prevents accidental cmake -B. -S.")
set(CMAKE_MESSAGE_CONTEXT_SHOW YES)
set(CMAKE_MESSAGE_CONTEXT xbuild)

set(XBUILD_PRELUDE_CMAKE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake" CACHE PATH "XBuild CMake Prelude directory")
set(XBUILD_PRELUDE_PACKAGES_DIR "${XBUILD_PRELUDE_CMAKE_DIR}/packages" CACHE PATH "XBuild CMake Prelude find_package directory")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/packages")
list(APPEND CMAKE_MESSAGE_CONTEXT prelude)

include(xbuild-prelude)


if (DEFINED ENV{XBUILD_FETCHCONTENT_BASE_DIR})
    # We use FORCE because the FetchContent for prelude sets FETCHCONTENT_BASE_DIR, which we want to override for all further fetched content
    set(FETCHCONTENT_BASE_DIR "$ENV{XBUILD_FETCHCONTENT_BASE_DIR}" CACHE PATH "Override FetchContent cache dir outside of the build tree to this path" FORCE)
endif()

# Non-top-level CMake
set(CMAKE_EXPORT_COMPILE_COMMANDS YES PARENT_SCOPE)
set(CMAKE_XCODE_GENERATE_SCHEME YES PARENT_SCOPE)
set(CMAKE_COLOR_DIAGNOSTICS YES PARENT_SCOPE) # Only valid for Ninja + CMake 3.24 installs
# Affects 1st time configure, ignored afterwards.
# NOTE: This should be moved to a custom toolchain file.
# Ensure the use of libc++ on all non-Windows platforms
#
# When configuring with CMAKE_OSX_DEPLOYMENT_TARGET 10.7, this setting is
# necessary because the default C++ toolchain uses libstdc++ -- So it must be
# set to use libc++ before project() to prevent this error during initial
# cmake:
#    clang: warning: libstdc++ is deprecated; move to libc++ with a minimum deployment target of OS X 10.9 [-Wdeprecated]
# NOTE: At some point this should be moved into custom toolchain files instead.
if (NOT WIN32)
    set(CMAKE_OBJCXX_FLAGS_INIT "-stdlib=libc++" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++" PARENT_SCOPE)
endif()
# Disables unnecessary compiler copyright information for RC files on Windows
set(CMAKE_RC_FLAGS_INIT "-nologo" PARENT_SCOPE)

# We do not want the average person calling these functions.
# They are reserved for the prelude. Hence the 🈯 (reserved) emoji.
#cmake_language(CALL 🈯::xbuild::prelude::cmake-file-api)
#cmake_language(CALL 🈯::xbuild::prelude::properties)
#cmake_language(CALL 🈯::xbuild::prelude::policies)
#cmake_language(CALL 🈯::xbuild::prelude::globals)