include_guard(GLOBAL)

#[[
This is the master cmake file, the top level project cmake should include
this file at the very begin before call project()
]]

set(CMAKE_MESSAGE_CONTEXT_SHOW YES)
set(CMAKE_MESSAGE_CONTEXT xbuild)
list(APPEND CMAKE_MESSAGE_CONTEXT prelude)

# Add xbuild-cmake dir to CMAKE_MODULE_PATH
message(STATUS "Add xbuild-cmake dir to CMAKE_MODULE_PATH (${CMAKE_CURRENT_LIST_DIR})")
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/packages")
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)

set_property(TARGET ${target} PROPERTY CMAKE_C_STANDARD_LIBRARIES_INIT "")
set_property(TARGET ${target} PROPERTY CMAKE_CXX_STANDARD_LIBRARIES_INIT "")
#set_property(TARGET ${target} PROPERTY CMAKE_C_IMPLICIT_LINK_LIBRARIES "")
#set_property(TARGET ${target} PROPERTY CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "")
#set_property(TARGET ${target} PROPERTY CMAKE_C_STANDARD_LIBRARIES "")
#set_property(TARGET ${target} PROPERTY CMAKE_CXX_STANDARD_LIBRARIES "")

# Enable Language
enable_language(C)
enable_language(CXX)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
  enable_language(ASM_MASM)
elseif ((CMAKE_SYSTEM_NAME STREQUAL "iOS") OR (CMAKE_SYSTEM_NAME STREQUAL "Darwin"))
  enable_language(OBJC)
  enable_language(OBJCXX)
endif()

if (XBUILD_CMAKE_IS_CHILD)
    message(STATUS "xbuild-cmake is child, need to set variable in parent scope")
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
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
else()
    message(STATUS "xbuild-cmake is not child (included directly)")
    set(CMAKE_EXPORT_COMPILE_COMMANDS YES)
    set(CMAKE_XCODE_GENERATE_SCHEME YES)
    set(CMAKE_COLOR_DIAGNOSTICS YES) # Only valid for Ninja + CMake 3.24 installs
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
        set(CMAKE_OBJCXX_FLAGS_INIT "-stdlib=libc++")
        set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
    endif()
    # Disables unnecessary compiler copyright information for RC files on Windows
    set(CMAKE_RC_FLAGS_INIT "-nologo")
endif()

# Include utilities
include(xbuild-util-options)
include(xbuild-internal-options)
include(xbuild-util-log)
include(xbuild-util-core)
include(xbuild-util-find)
include(xbuild-util-cmake)
include(xbuild-env)
include(xbuild-project)
