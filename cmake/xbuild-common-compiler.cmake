# XBuild support 3 types of compilers
#   - Clang = LLVM Clang (clang.llvm.org), Linux
#   - AppleClang = Apple Clang (apple.com), MacOS
#   - MsClang = Microsoft Clang (microsoft.com), Windows
#   - MSVC = Microsoft Visual Studio (microsoft.com), Windows
set(CL_CLANG OFF)
set(CL_APPLE_CLANG OFF)
set(CL_MS_CLANG OFF)
set(CL_MSVC OFF)

# Set correct compiler
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang$")
    SET(CLANG ON)
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        SET(CL_APPLE_CLANG ON)
    elseif("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
        SET(CL_MS_CLANG ON)
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    SET(CL_MSVC ON)
else()
    message(FATAL_ERROR "Compiler '${CMAKE_CXX_COMPILER_ID}' is unsupported")
endif()

#
#  COMMON Compiler Settings
#

# Always use C++17 without any compiler extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)

#
#  Compiler Settings for CL_MSVC
#
if(CL_MSVC)
    # Reproducible builds
    add_compile_options(/Brepro)
    add_link_options(/Brepro)

    add_compile_options(/EHsc) # Default exception handling model
    add_compile_options(/MP) # MultiProcessorCompilation true
    add_compile_options(/Gm-) # MinimalRebuild false
    add_compile_options(/utf-8) # Assume all source files are /utf-8 even if they don't contain a BOM

    # This flag is very important for correct floating point behavior.  Under VS2015 it was
    # possible to use /fp:fast, but starting with VS2017 the optimizations have gotten more
    # aggressive with behavior surrounding Inf and NaN and it's no longer safe to use
    # /fp:fast with Roblox code.
    add_compile_options(/fp:precise) # Floating Point Model

    add_compile_options(/Oy-) # OmitFramePointers false
    add_compile_options(/GR) # Enable Run-Time Type Information
    
    # MSVC doesn't by default use the correct value of __cplusplus unless you force it to.
    add_compile_options(/Zc:__cplusplus)

    ### WARNINGS
    add_compile_options(/WX) # Treat warnings as errors
    add_compile_options(/W3) # Enable warnings up to level 3 on msvc and -Wall on clang
    #   - Enabled
    add_compile_options(/we4505) # Unused local function
    add_compile_options(/we4101) # Unreferenced local variable
    add_compile_options(/we4477) # Format string argument type mismatch
    add_compile_options(/we4189) # local variable is initialized but not referenced (level 4)
    add_compile_options(/we4062) # All enumerators in a switch must be handled by an explicit or default case
    #   - Disabled
    add_compile_options(/wd4018) # Signed/Unsigned mismatch

endif()

#
#  Compiler Settings for CL_MS_CLANG
#
if(CL_MS_CLANG)
    # Unfortunately, Microsoft is not supported currently
    message(FATAL_ERROR "Compiler '${CMAKE_CXX_COMPILER_ID}' is currently unsupported")
endif()

#
#  Compiler Settings for CL_CLANG
#
if(CL_CLANG)
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

    ### WARNINGS
    add_compile_options(-Wall)
    add_compile_options(-Werror)
    #  - Enabled
    add_compile_options(-Wunused-function)
    add_compile_options(-Wunused-variable)
    #  - Disabled
    # We use -Wno-unknown-warning-option because we support various different versions of
    # clang in order to be able to experiment with newer compiler versions, and some of
    # these have introduced new warnings that aren't understood by older versions.
    add_compile_options(-Wno-unknown-warning-option)
    # Suppress "arithmetic between different enumeration types" in abseil-cpp/spinlock.cc
    add_compile_options(-Wno-anon-enum-enum-conversion)
    add_compile_options(-Wno-unused-but-set-variable)
    add_compile_options(-Wno-unused-command-line-argument)
    
    if (CL_APPLE_CLANG)
        # Options for AppleClang Only
    else()
        # Options for Non-AppleClang Only
    endif()
endif()
