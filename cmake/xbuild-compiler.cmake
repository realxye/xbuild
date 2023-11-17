include_guard(GLOBAL)

# set project configuration
include(xbuild-compiler-config)

# Output debug information: compiler
if (XBD_OPT_DEBUG_VERBOSE)
    message(STATUS "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Clear all
set(XBD_CL_CLANG OFF)       # Set when any flavor of clang is in use.
set(XBD_CL_APPLE_CLANG OFF) # Set only when AppleClang is the compiler.
set(XBD_CL_MSVC_CLANG OFF)  # Set only when clang-cl (Microsoft Clang) is the compiler.
set(XBD_CL_MSVC OFF)        # Set only when Microsoft C++ is the compiler.

# Always use C++17 without any compiler extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)

# select compiler profile
if(XBD_PLATFORM_WINDOWS)
    include(xbuild-compiler-msvc)
else()
    include(xbuild-compiler-llvm)
endif()
