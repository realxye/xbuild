
# Ensure environment has been set
if (NOT XBD_ENV_WINDOWS)
    message(FATAL_ERROR "Unsupported build environment. Windows target can only be built on Windows")
endif()

message(STATUS "Target Platform: Windows")

# set variables
#   - XBuild Variables
set(XBD_PLATFORM_NAME "Windows")
set(XBD_PLATFORM_DESKTOP ON)
#   - CMake Variables
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 1)
set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)
if(MSVC)
    # For MSVC, CMake sets certain flags to defaults we want to override.
    # This replacement code is taken from sample in the CMake Wiki at
    # https://gitlab.kitware.com/cmake/community/wikis/FAQ#dynamic-replace.
    foreach (flag_var
                CMAKE_C_FLAGS CMAKE_CXX_FLAGS
                CMAKE_C_FLAGS_OPTIMIZED CMAKE_CXX_FLAGS_OPTIMIZED
                CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE
                CMAKE_C_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_MINSIZEREL
                CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_RELWITHDEBINFO
                CMAKE_C_FLAGS_NOOPT CMAKE_CXX_FLAGS_NOOPT
                )
        # We set this to /EHsc in some places and /EHa in other places.  So if we allow
        # /EHsc on the command line initially we'll get warnings if we try to change it.
        # Ideally it's on the COMPILE_OPTIONS directory proprety so that an indivdiual
        # target can easily override it.
        string(REPLACE "/EHsc" "" ${flag_var} "${${flag_var}}")
    endforeach()

    # Since 3.18.0 CMake changed `<CMAKE_LINKER> /lib` to `<CMAKE_AR>` in `CMAKE_{lang}_CREATE_STATIC_LIBRARY` commands,
    # `lib.exe` is meant by `CMAKE_AR`: https://gitlab.kitware.com/cmake/cmake/-/commit/55196a1440e26917d40e6a7a3eb8d9fb323fa657
    # Better solution would be to update toolchains (use `lib.exe` instead of `link.exe`) and params passed to configs by
    # `common.py` (`CMAKE_LINKER` to `CMAKE_AR`). See https://jira.rbx.com/browse/CLI-35509.
    set(CMAKE_CXX_CREATE_STATIC_LIBRARY  "<CMAKE_LINKER> /lib ${CMAKE_CL_NOLOGO} <LINK_FLAGS> /out:<TARGET> <OBJECTS> ")
    set(CMAKE_C_CREATE_STATIC_LIBRARY  "<CMAKE_LINKER> /lib ${CMAKE_CL_NOLOGO} <LINK_FLAGS> /out:<TARGET> <OBJECTS> ")
endif()
string (REPLACE "/D_WINDOWS" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# Set predefines
#   - XBuild predefines
add_compile_definitions(XBD_PLATFORM_WINDOWS)
add_compile_definitions(XBD_PLATFORM_NAME="${XBD_PLATFORM_NAME}")
add_compile_definitions(XBD_PLATFORM_DESKTOP)
#   - CMake predefines
add_compile_definitions(_UNICODE UNICODE)
add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
add_compile_definitions(_SCL_SECURE_NO_WARNINGS)
add_compile_definitions(NOMINMAX)
add_compile_definitions(WIN32_LEAN_AND_MEAN)

# Set compile options
add_compile_options("$<$<CONFIG:Release>:/O2;/Ob2;/Oi;/Gy;/GF;/GS->")
add_compile_options($<$<CONFIG:Release>:${debug-information-format}>)

# Set link options
if(MSVC)
    add_link_options(/LARGEADDRESSAWARE /DEBUG:FULL)
endif()
add_link_options("$<$<CONFIG:Optimized>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF>")
add_link_options("$<$<CONFIG:Release>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF>")

# Macro to make platform defines
macro(xbd_make_platform_defs VERSION SERVICE_PACK)
    set(WINDOWS_TARGET_VERSION ${VERSION})
    set(WINDOWS_TARGET_SERVICE_PACK ${SERVICE_PACK})
    add_compile_definitions(
        _WIN32_WINNT=${VERSION}
        WINVER=${VERSION}
        NTDDI_VERSION=${VERSION}${SERVICE_PACK}
    )
endmacro(xbd_make_platform_defs)

macro(xbd_target_windows_7)
    xbd_make_platform_defs(0x0601 0000)
endmacro()

macro(xbd_target_windows_8)
    xbd_make_platform_defs(0x0603 0000)
endmacro()

macro(xbd_target_windows_10)
    xbd_make_platform_defs(0x0A00 0000)
endmacro()

# Set default target to Windows 10
xbd_target_windows_10()

# Enable LTCG on Release builds
if (XBD_OPT_ENABLE_LTCG)
    add_link_options($<$<CONFIG:Release>:/LTCG>)
    add_compile_options($<$<CONFIG:Release>:/GL>)
    string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE " /LTCG")
endif()

# Exceptions
macro(xbd_target_use_seh_exceptions target)
    # First remove /EHsc from target compile options
    get_target_property(OPTIONS ${target} "COMPILE_OPTIONS")
    list(REMOVE_ITEM OPTIONS "/EHsc")
    set_target_properties("${target}" PROPERTIES "COMPILE_OPTIONS" "${OPTIONS}")
    # Then add /EHa
    target_compile_options(${target} PRIVATE "/EHa")
endmacro()
