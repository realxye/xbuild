
# Sanity check
if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(FATAL_ERROR "xcbuild-compiler-msvc.cmake is for MSVC only")
endif()

# Set only when Microsoft C++ is the compiler.
set(XBD_CL_MSVC ON)

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


# Reproducible builds
add_compile_options(/Brepro)
add_link_options(/Brepro)
add_compile_options(/EHsc) # Default exception handling model
# This flag is very important for correct floating point behavior.  Under VS2015 it was
# possible to use /fp:fast, but starting with VS2017 the optimizations have gotten more
# aggressive with behavior surrounding Inf and NaN and it's no longer safe to use
# /fp:fast with Roblox code.
add_compile_options(/fp:precise) # Floating Point Model
add_compile_options(/Oy-) # OmitFramePointers false
add_compile_options(/GR) # Enable Run-Time Type Information
### WARNINGS
add_compile_options(/WX) # Treat warnings as errors
add_compile_options(/W3) # Enable warnings up to level 3 on msvc and -Wall on clang
add_compile_options(/we4477) # Format string argument type mismatch
add_compile_options(/wd4018) # Signed/Unsigned mismatch
add_compile_options(/we4189) # local variable is initialized but not referenced (level 4)
# C4731: frame pointer register 'ebx' modified by inline assembly code
# This warning is triggered by inline assembly in our VMProtect markers when LTCG is used
# for codegen. Disable it to get VMProtect working with LTCG.
add_compile_options(/wd4731)
# These are some other warnings that are worth considering but that we are not enabling:
# C4101: Unreferenced local variable. This is a level 3 warning so it's already enabled (unless we change the default warning level).
#add_compile_options(/we4101)
# C4100: Unreference formal parameter. There's not an equivalent warning in clang and we want all targets to error the same way.
#add_compile_options(/we4100)
# C4505: Unused local function has been removed. This is very similar to -Wunused-function and we may want to enable it in the future
#        to improve consistency with clang. However, to enable it we would have to fix many errors and this needs to be studied in more
#        detail.
#add_compile_options(/we4505)


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