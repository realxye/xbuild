
# Sanity check
if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(FATAL_ERROR "xcbuild-compiler-msvc.cmake is for MSVC only")
endif()

# Set only when Microsoft C++ is the compiler.
set(XBD_CL_MSVC ON)
message(STATUS "Compiler: MSVC")

# Don't continue if we have known bad compiler version
#if(${CMAKE_CXX_COMPILER_VERSION} VERSION_EQUAL 19.12.25831)
#    message(FATAL_ERROR "This version of MSVC (${CMAKE_CXX_COMPILER_VERSION}) contains a known Internal Compiler Exception and will fail. "
#                        "XBuild requires at least 19.16.27032.1 to build properly."
#endif()
if(${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 19.16.27032.1)
    message(WARNING "The current version of MSVC (${CMAKE_CXX_COMPILER_VERSION}) is unsupported.  XBuild requires at least "
                    "19.16.27032.1 to build properly.  Please upgrade your compiler. You may experience compilation or "
                    "build instability.")
endif()

# Set compiler common options
include(xbuild-compiler-common-options)

if("${CMAKE_GENERATOR}" STREQUAL "Ninja")
    add_compile_options(/we5038) # enable initialization order warning
else()
    # Don't use /MP with Ninja, as it schedules compilations independently anyway.
    add_compile_options(/MP) # MultiProcessorCompilation true
endif()
add_compile_options(/utf-8) # Assume all source files are /utf-8 even if they don't contain a BOM
add_compile_options(/Zc:strictStrings) # Parity with CLANG

# MSVC doesn't by default use the correct value of __cplusplus unless you force it to.
add_compile_options(/Zc:__cplusplus)