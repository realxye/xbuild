# This file holds compiler-wide settings and initialization.  It is included
# first, before any other cmake file, so it should use as little logic as
# possible that is based on anything other than the compiler.  For example,
# it should not do anything based off of spec, build configuration, host or
# target platform.

if(NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang$")
    message(FATAL_ERROR "xcbuild-compiler-llvm.cmake is for Clang only")
endif()

# Check which clag is being used
SET(XBD_CLANG ON)
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
    SET(XBD_CL_APPLE_CLANG ON)
elseif("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
    SET(XBD_CL_MSVC_CLANG ON)
else()
    message(FATAL_ERROR "Compiler (${CMAKE_CXX_COMPILER_ID}) is unsupported")
endif()

# Set compiler common options
include(xbuild-compiler-common-options)

# Set clang common options
if(XBD_OPT_BUILD_TIMING)
    add_compile_options(-ftime-trace)
endif()
add_compile_options(-Wrange-loop-analysis)

# Generic cl options that are needed with MSVC CL or clang-cl
if(XBD_CL_MSVC_CLANG)
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

    # TODO (CLI-43749) consolidate more cross-compiler compile options into rbx_add_compile_option
    rbx_add_compile_option(-Wno-switch /we4062) # All enumerators in a switch must be handled by an explicit or default case

    add_compile_options(/we4477) # Format string argument type mismatch
    add_compile_options(/wd4018) # Signed/Unsigned mismatch
    add_compile_options(/we4189) # local variable is initialized but not referenced (level 4)

    # C4731: frame pointer register 'ebx' modified by inline assembly code
    # This warning is triggered by inline assembly in our VMProtect markers when LTCG is used
    # for codegen. Disable it to get VMProtect working with LTCG.
    add_compile_options(/wd4731)

    # These are some other warnings that are worth considering but that we are not enabling:
    # C4101: Unreferenced local variable. This is a level 3 warning so it's already enabled (unless we change the default warning level).
    add_compile_options(/we4101)
    # C4100: Unreference formal parameter. There's not an equivalent warning in clang and we want all targets to error the same way.
    add_compile_options(/we4100)
    # C4505: Unused local function has been removed. This is very similar to -Wunused-function and we may want to enable it in the future
    #        to improve consistency with clang. However, to enable it we would have to fix many errors and this needs to be studied in more
    #        detail.
    add_compile_options(/we4505)

    #
    # clang-cl only options
    #
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
    add_compile_options(-Wno-switch) # All enumerators in a switch must be handled by an explicit or default case

    # ppltasks.h, which is a Microsoft header uses some non-conformant C++ that
    # clang-cl rejects. Luckily they provide a workaround for this in their
    # header files, which causes a different construct to be used instead.
    add_compile_definitions(_PPLTASKS_NO_STDFUNC)

    # clang-12 w/ clang-cl.exe
    # exposes a bunch of unused functions and variables, silence them for now
    add_compile_options(-Wno-unused-function)
    add_compile_options(-Wno-unused-variable)
    # clang-12: clang-cl.exe error: argument unused during compilation: '/GL'
    add_compile_options(-Wno-unused-command-line-argument)
endif()

if(NOT XBD_CL_MSVC_CLANG)
    # Report libc++ version, or fail if libc++ doesn't work for some reason.
    #   - This check is informative only.
    #   - This check is disabled for Xcode, which throws error on it.
    #   - This check is disabled for PS4/PS5 Playstation toolchains.
    #   - CMake will error in the try_compile if the PS4PSSL/PS5PSSL language modules
    #     are not installed in the CMake dist share/cmake-ver/Modules/ dir
    #   - Engine keeps these files in Client/cmake/(PS4|PS5)
    #     which fails's CMake's try_compile, but works for regular compiles
    if(NOT("${CMAKE_GENERATOR}" STREQUAL "Xcode") AND NOT CMAKE_SYSTEM_NAME STREQUAL "ORBIS" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Prospero")
        try_compile(
            LIBCPP_COMPILE_RESULT                                   # <resultVar>
            "${RBX_BINARY_DIR}/TryCompile"                          # <bindir>
            "${RBX_SOURCE_DIR}/cmake/TryCompile/LibCppVersion"      # <srcdir>
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
    add_compile_options($<$<BOOL:${XBD_OPT_TREAT_WARNINGS_AS_ERRORS}>:-Werror>)

    # We use -Wno-unknown-warning-option because we support various different versions of
    # clang in order to be able to experiment with newer compiler versions, and some of
    # these have introduced new warnings that aren't understood by older versions.
    add_compile_options(-Wno-unknown-warning-option)

    add_compile_options(-Wno-unused-but-set-variable)
endif()

if(XBD_CL_CLANG AND NOT XBD_CL_MSVC_CLANG AND (${XBD_OPT_USE_SANITIZER} STREQUAL "none"))
    # Normally this is implied by C++17, but ios is special in that it only supports aligned allocation functions starting in iOS 11,
    # independent of C++ standard version.  The workaround we use here is to tell the compiler that we're implementing them ourselves,
    # and we don't need the compiler to generate them for us.  Note that memory tracking is disabled when sanitizers are enabled, because
    # in that case the sanitizer runtime interposes its own operators at runtime.
    add_compile_options(-faligned-allocation)
endif()
