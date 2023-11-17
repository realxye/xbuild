
# Sanity check
if(NOT XBD_ENV_WINDOWS)
    message(FATAL_ERROR "xcbuild-compiler-msvc.cmake can only be used in Windows environment")
endif()

if(NOT MSVC)
    message(FATAL_ERROR "MSVC is not defined. xcbuild-compiler-msvc.cmake only support MSVC")
endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(XBD_CL_MSVC ON)
    message(STATUS "Compiler: MSVC")
    if (MSVC)
        message(STATUS "MSVC is defined")
    else()
        message(STATUS "MSVC is NOT defined")
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang$" AND "${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
    SET(XBD_CLANG ON)
    SET(XBD_CL_MSVC_CLANG ON)
    message(STATUS "Compiler: MSVC Clang")
    if (MSVC)
        message(STATUS "MSVC is defined")
    else()
        message(STATUS "MSVC is NOT defined")
    endif()
else()
    message(FATAL_ERROR "Compiler (${CMAKE_CXX_COMPILER_ID}) is unsupported")
endif()

# Don't continue if we have known bad compiler version
#if(${CMAKE_CXX_COMPILER_VERSION} VERSION_EQUAL 19.12.25831)
#    message(FATAL_ERROR "This version of MSVC (${CMAKE_CXX_COMPILER_VERSION}) contains a known Internal Compiler Exception and will fail. "
#                        "XBuild requires at least 19.16.27032.1 to build properly."
#endif()
if(XBD_CL_MSVC AND ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 19.16.27032.1)
    message(WARNING "The current version of MSVC (${CMAKE_CXX_COMPILER_VERSION}) is unsupported.  XBuild requires at least "
                    "19.16.27032.1 to build properly.  Please upgrade your compiler. You may experience compilation or "
                    "build instability.")
endif()

# Set common configurations
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 1)
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)

# Set compiler common options
set(XBD_DEFAULT_COMPILE_OPTIONS
    "/nologo" # Suppress Startup Banner
    "/Brepro" # Reproducible builds
    "/MP" # MultiProcessorCompilation true
    "/EHsc" # Default exception handling model
    "/fp:precise" # Floating Point Model
    "/Oi" # Enable Intrinisic Functions
    "/Oy-" # OmitFramePointers false
    "/GF" # Enable String Pooling
    "/GR" # Enable Run-Time Type Information
    "/Gy" # Enable Function-Level Linking
    "/Zi" # Debug Information Format (Program Database)
    "/utf-8" # Assume all source files are /utf-8 even if they don't contain a BOM
    "/Zc:strictStrings" # Parity with CLANG
    "/Zc:wchar_t" # Treat Wchar_t As Built-in Type
    "/Zc:__cplusplus" # MSVC doesn't by default use the correct value of __cplusplus unless you force it to.
    "/std:c++17" # Always support C++ 17
    "/std:c11" # Always support C11
    "/WX" # Treat warnings as errors
    "/W3" # Enable warnings up to level 3 on msvc and -Wall on clang
    "/external:W0" # Set external header warning level to zero
    "/we4062" # All enumerators in a switch must be handled by an explicit or default case
    "/we4477" # Format string argument type mismatch
    "/we4100" # Unreference formal parameter. There's not an equivalent warning in clang and we want all targets to error the same way.
    "/we4101" # Unreferenced local variable. This is a level 3 warning so it's already enabled (unless we change the default warning level).
    "/we4189" # Local variable is initialized but not referenced (level 4)
    "/we4505" # Unused local function has been removed. This is very similar to -Wunused-function
    "/wd4018" # Signed/Unsigned mismatch
    )

# Set compiler common definitions
set(XBD_DEFAULT_COMPILE_DEFINITIONS
    "WINNT=1"
    "XBD_PLATFORM_WINDOWS"
    "XBD_PLATFORM_DESKTOP"
    "XBD_PLATFORM_NAME=\"${XBD_PLATFORM_NAME}\""
    "_UNICODE"
    "UNICODE"
    "NOMINMAX"
    "WIN32_LEAN_AND_MEAN"
    "_CRT_SECURE_NO_WARNINGS"
    "_SCL_SECURE_NO_WARNINGS"
    )

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    list(APPEND XBD_DEFAULT_COMPILE_DEFINITIONS "_X86_=1;i386=1")
    set(XBD_PLATFORM "X86")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    list(APPEND XBD_DEFAULT_COMPILE_DEFINITIONS "_WIN64;_AMD64_;AMD64")
    set(XBD_PLATFORM "X64")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

# Set linker common flags
string(CONCAT XBD_DEFAULT_LINK_FLAGS
    "/NOLOGO " # Suppress Startup Banner
    "/INCREMENTAL:NO " # Disable incremental linking
    "/MANIFEST " # Generate Manifest file
    "/DEBUG:FULL " # Generate Debug Information optimized for sharing and publishing
    "/OPT:REF " # Enable references
    "/OPT:ICF " # Enable COMDAT Folding
    "/SUBSYSTEM:WINDOWS " # Defaul to create Windows Subsystem
    "/MACHINE:${XBD_PLATFORM} " # Target machine
    "/LARGEADDRESSAWARE " # Enable Large Addresses
    "/WX " #
    )


# Export common compile options/definitions and link flags
set(XBD_DEFAULT_COMPILE_OPTIONS "${XBD_DEFAULT_COMPILE_OPTIONS}" CACHE INTERNAL "XBuild default compile options")
set(XBD_DEFAULT_COMPILE_DEFINITIONS "${XBD_DEFAULT_COMPILE_DEFINITIONS}" CACHE INTERNAL "XBuild default compile definitions")
set(XBD_DEFAULT_LINK_FLAGS "${XBD_DEFAULT_LINK_FLAGS}" CACHE INTERNAL "XBuild default link flags")

function (xbd_set_target_default_compiler_options target)
endfunction()

function (xbd_set_target_default_compiler_definitions target)
endfunction()

function (xbd_set_target_default_link_options target)
endfunction()

## Set compile options
#message(STATUS "Set compile options")
#add_compile_options("$<$<CONFIG:Release>:/O2;/Ob2;/Oi;/Gy;/GF;/GS->")
#add_compile_options($<$<CONFIG:Release>:${debug-information-format}>)
#
## Set link options
#message(STATUS "Set link options")
#if(MSVC)
#    add_link_options(/LARGEADDRESSAWARE /DEBUG:FULL)
#endif()
#add_link_options("$<$<CONFIG:Debug>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF>")
#add_link_options("$<$<CONFIG:Release>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF>")
#
## Macro to make platform defines
#macro(xbd_make_platform_defs VERSION SERVICE_PACK)
#    set(WINDOWS_TARGET_VERSION ${VERSION})
#    set(WINDOWS_TARGET_SERVICE_PACK ${SERVICE_PACK})
#    add_compile_definitions(
#        _WIN32_WINNT=${VERSION}
#        WINVER=${VERSION}
#        NTDDI_VERSION=${VERSION}${SERVICE_PACK}
#    )
#endmacro(xbd_make_platform_defs)
#
#macro(xbd_target_windows_7)
#    xbd_make_platform_defs(0x0601 0000)
#endmacro()
#
#macro(xbd_target_windows_8)
#    xbd_make_platform_defs(0x0603 0000)
#endmacro()
#
#macro(xbd_target_windows_10)
#    xbd_make_platform_defs(0x0A00 0000)
#endmacro()
#
## Set default target to Windows 10
#xbd_target_windows_10()
#
## Enable LTCG on Release builds
#if (XBD_OPT_ENABLE_LTCG)
#    add_link_options($<$<CONFIG:Release>:/LTCG>)
#    add_compile_options($<$<CONFIG:Release>:/GL>)
#    string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE " /LTCG")
#endif()
#
## Exceptions
#macro(xbd_target_use_seh_exceptions target)
#    # First remove /EHsc from target compile options
#    get_target_property(OPTIONS ${target} "COMPILE_OPTIONS")
#    list(REMOVE_ITEM OPTIONS "/EHsc")
#    set_target_properties("${target}" PROPERTIES "COMPILE_OPTIONS" "${OPTIONS}")
#    # Then add /EHa
#    target_compile_options(${target} PRIVATE "/EHa")
#endmacro()
