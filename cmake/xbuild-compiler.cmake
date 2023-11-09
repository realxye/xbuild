include_guard(GLOBAL)

# Enable Language
enable_language(C)
enable_language(CXX)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
  enable_language(ASM_MASM)
elseif ((CMAKE_SYSTEM_NAME STREQUAL "iOS") OR (CMAKE_SYSTEM_NAME STREQUAL "Darwin"))
  enable_language(OBJC)
  enable_language(OBJCXX)
endif()

# Output debug information: compiler
if (XBD_OPT_DEBUG_VERBOSE)
    message("[XBD] CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
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
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang$")
    include(xbuild-compiler-llvm)
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    include(xbuild-compiler-msvc)
else()
    message(FATAL_ERROR "Compiler (${CMAKE_CXX_COMPILER_ID}) is unsupported")
endif()

# set project configuration
include(xbuild-compiler-config)
