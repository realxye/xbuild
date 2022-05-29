# XBuild support 4 types of compilers
#   - Clang = LLVM Clang (clang.llvm.org)
#   - AppleClang = Apple Clang (apple.com)
#   - MSVC = Microsoft Visual Studio (microsoft.com)
set(CL_CLANG OFF)
set(CL_APPLE_CLANG OFF)
set(CL_MSCLANG OFF)
set(CL_MSVC OFF)

# Set correct compiler
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang$")
    SET(CLANG ON)
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        SET(CL_APPLE_CLANG ON)
    elseif("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
        SET(CL_MSCLANG ON)
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    SET(CL_MSVC ON)
else()
    message(FATAL_ERROR "Compiler '${CMAKE_CXX_COMPILER_ID}' is unsupported")
endif()

# Generic cl options that are needed with MSVC CL or clang-cl
if(CL_MSCLANG OR CL_MSVC)
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
    if (CL_MSVC)
        # Warnings for MSVC
        #   - Enabled
        add_compile_options(/we4505) # Unused local function
        add_compile_options(/we4101) # Unreferenced local variable
        add_compile_options(/we4477) # Format string argument type mismatch
        add_compile_options(/we4189) # local variable is initialized but not referenced (level 4)
        add_compile_options(/we4062) # All enumerators in a switch must be handled by an explicit or default case
        #   - Disabled
        add_compile_options(/wd4018) # Signed/Unsigned mismatch
    else()
        # Warnings for Clang
        add_compile_options(-Wunused-function)  # Unused local function
        add_compile_options(-Wno-switch)        # All enumerators in a switch must be handled by an explicit or default case
    endif()

endif()

# CL_MSCLANG only options
if(CL_MSCLANG)
    add_compile_options(-Wno-unknown-warning-option)
    add_compile_options(-Wno-microsoft-include)
    add_compile_options(-Wno-microsoft-exception-spec)
    add_compile_options(-Wno-enum-compare-switch)
    add_compile_options(-Wno-reorder)
    add_compile_options(-Wno-reorder-ctor)
    add_compile_options(-Wno-parentheses)
    add_compile_options(-Wno-delete-non-abstract-non-virtual-dtor)
    add_compile_options(-Wno-microsoft-extra-qualification)
    add_compile_options(-Wno-logical-op-parentheses)
    add_compile_options(-Wno-invalid-noreturn)
    add_compile_options(-Wno-typename-missing)
    add_compile_options(-Wno-invalid-token-paste)
    add_compile_options(-Wno-writable-strings)
    add_compile_options(-Wno-nonportable-include-path)
    add_compile_options(-Wno-extra-tokens)
    add_compile_options(-Wno-c99-designator)
    add_compile_options(-Wno-c++11-narrowing)
    add_compile_options(-Wno-ignored-pragma-optimize)
    add_compile_options(-Wno-pragma-pack)
    add_compile_options(-Wno-microsoft-enum-forward-reference)
    add_compile_options(-Wno-sometimes-uninitialized)
    add_compile_options(-Wno-inconsistent-missing-override)
    add_compile_options(-Wno-format)
    add_compile_options(-Wno-ignored-attributes)
    add_compile_options(-Wno-tautological-constant-out-of-range-compare)
    add_compile_options(-Wno-missing-braces)
    add_compile_options(-Wno-macro-redefined)
    add_compile_options(-Wno-pessimizing-move)
    add_compile_options(-Wno-microsoft-template)
    add_compile_options(-Wno-unknown-pragmas)
    add_compile_options(-Wno-ignored-pragmas)
    add_compile_options(-Wno-invalid-constexpr)
    add_compile_options(-Wno-extra-qualification)
    add_compile_options(-Wno-microsoft-unqualified-friend)
    add_compile_options(-Wno-delete-incomplete)
    add_compile_options(-Wno-non-pod-varargs)

    # clang-12 w/ clang-cl.exe
    # exposes a bunch of unused functions and variables, silence them for now
    add_compile_options(-Wno-unused-function)
    add_compile_options(-Wno-unused-variable)
    # clang-12: clang-cl.exe error: argument unused during compilation: '/GL'
    add_compile_options(-Wno-unused-command-line-argument)
endif()

# MSVC only options
if(CL_MSVC)
    if("${CMAKE_GENERATOR}" STREQUAL "Ninja")
	    add_compile_options(/we5038) # enable initialization order warning
    else()
        # Don't use /MP with Ninja, as it schedules compilations independently anyway.
        add_compile_options(/MP) # MultiProcessorCompilation true
    endif()
    add_compile_options(/Gm-) # MinimalRebuild false
    add_compile_options(/utf-8) # Assume all source files are /utf-8 even if they don't contain a BOM
endif()

# CLANG except CL_MSCLANG
if(CL_CLANG AND NOT CL_MSCLANG)
    # Report libc++ version, or fail if libc++ doesn't work for some reason.
    # This check is informative only. Xcode throws error on it.
    if(NOT("${CMAKE_GENERATOR}" STREQUAL "Xcode"))
        try_compile(
            LIBCPP_COMPILE_RESULT                                   # <resultVar>
            "${CMAKE_BINARY_DIR}/TryCompile"                        # <bindir>
            "${XBUILDROOT}/cmake/TryCompile/LibCppVersion"          # <srcdir>
            PrintLibCppVersion                                      # <projectName>
            OUTPUT_VARIABLE LIBCPP_COMPILE_OUTPUT
            )
        if (NOT LIBCPP_COMPILE_RESULT)
            message(FATAL_ERROR "Could not find a working libc++, exiting.  LIBCPP_COMPILE_OUTPUT = ${LIBCPP_COMPILE_OUTPUT}")
        endif()

        string(REGEX MATCH "libc\\+\\+ version: ([0-9]+) " LIBCPP_VERSION_MATCH "${LIBCPP_COMPILE_OUTPUT}")
        message(STATUS "Found libc++ version: ${CMAKE_MATCH_1}")
    endif()

	# This is needed so that sqrt() / sqrtf() compile into a single instruction on x86/ARM
    add_compile_options(-fno-math-errno)

    add_compile_options(-Wall)
    add_compile_options(-Werror)
    # We use -Wno-unknown-warning-option because we support various different versions of
    # clang in order to be able to experiment with newer compiler versions, and some of
    # these have introduced new warnings that aren't understood by older versions.
    add_compile_options(-Wno-unknown-warning-option)

    # Suppress "arithmetic between different enumeration types" in abseil-cpp/spinlock.cc
    add_compile_options(-Wno-anon-enum-enum-conversion)

    add_compile_options(-Wno-unused-but-set-variable)
endif()

#
#  COMMON Compiler Settings
#

# Always use C++17 without any compiler extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
if(CL_MSVC)
    # MSVC doesn't by default use the correct value of __cplusplus unless you force it to.
    add_compile_options(/Zc:__cplusplus)
endif()
