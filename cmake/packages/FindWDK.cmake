include_guard(GLOBAL)

# FindWDK
# ----------
#
# This module searches for the installed Windows Development Kit (WDK) and
# exposes commands for creating kernel drivers and kernel libraries.
#
# Output variables:
# - `WDK_ROOT` -- where WDK is installed
# - `WDK_VERSION` -- the version of the selected WDK
# - `WDK_WINVER` -- the WINVER used for kernel drivers and libraries
#        (default value is `0x0601` and can be changed per target or globally)
# - `WDK_NTDDI_VERSION` -- the NTDDI_VERSION used for kernel drivers and libraries,
#                          if not set, the value will be automatically calculated by WINVER
#        (default value is left blank and can be changed per target or globally)
# - `WDK_COMPILE_FLAGS` -- WDK compile flag
# - `WDK_COMPILE_DEFINITIONS` -- WDK compile definitions
# - `WDK_COMPILE_DEFINITIONS_DEBUG` -- WDK compile definitions (Debug)
# - `WDK_LINK_FLAGS` -- WDK link flags
# - `WDK_PLATFORM` -- WDK platform
#
# Example usage:
#
#   find_package(WDK REQUIRED)
#

if(DEFINED ENV{WDKContentRoot})
    file(GLOB WDK_NTDDK_FILES
        "$ENV{WDKContentRoot}/Include/*/km/ntddk.h" # WDK 10
    )
else()
    file(GLOB WDK_NTDDK_FILES
        "C:/Program Files*/Windows Kits/*/Include/*/km/ntddk.h" # WDK 10
    )
endif()

if(WDK_NTDDK_FILES)
    if (NOT CMAKE_VERSION VERSION_LESS 3.18.0)
        list(SORT WDK_NTDDK_FILES COMPARE NATURAL) # sort to use the latest available WDK
    endif()
    list(GET WDK_NTDDK_FILES -1 WDK_LATEST_NTDDK_FILE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(WDK REQUIRED_VARS WDK_LATEST_NTDDK_FILE)

if (NOT WDK_LATEST_NTDDK_FILE)
    message(STATUS "WDK: Not found" )
    return()
endif()

# Parse version and path
# - "C:/Program Files*/Windows Kits/10/Include/10.0.22621.0/km/ntddk.h"
get_filename_component(WDK_ROOT ${WDK_LATEST_NTDDK_FILE} DIRECTORY) # "C:/Program Files*/Windows Kits/10/Include/10.0.22621.0/km"
get_filename_component(WDK_ROOT ${WDK_ROOT} DIRECTORY)              # "C:/Program Files*/Windows Kits/10/Include/10.0.22621.0"
get_filename_component(WDK_LATEST_VERSION ${WDK_ROOT} NAME)                # "10.0.22621.0"
get_filename_component(WDK_ROOT ${WDK_ROOT} DIRECTORY)              # "C:/Program Files*/Windows Kits/10/Include"
get_filename_component(WDK_ROOT ${WDK_ROOT} DIRECTORY)              # "C:/Program Files*/Windows Kits/10"

# Get all available versions
foreach(NTDDK_FILE ${WDK_NTDDK_FILES})
    get_filename_component(NTDDK_FILE "${NTDDK_FILE}" DIRECTORY)  # "C:/Program Files*/Windows Kits/10/Include/10.0.22621.0/km"
    get_filename_component(NTDDK_FILE "${NTDDK_FILE}" DIRECTORY)  # "C:/Program Files*/Windows Kits/10/Include/10.0.22621.0"
    get_filename_component(NTDDK_VERSION "${NTDDK_FILE}" NAME)    # "10.0.22621.0"
    list(APPEND WDK_ALL_VERSIONS "${NTDDK_VERSION}")
endforeach()

# Export WDK Information
set(WDK_FOUND ON CACHE BOOL "WDK is found" FORCE)
set(WDK_ROOT "${WDK_ROOT}" CACHE STRING "WDK dir" FORCE)
set(WDK_LATEST_VERSION "${WDK_LATEST_VERSION}" CACHE STRING "WDK latest version" FORCE)
set(WDK_ALL_VERSIONS "${WDK_ALL_VERSIONS}" CACHE STRING "WDK available versions" FORCE)

# Print success message
message(STATUS "WDK: Found")
message(STATUS "   - Root: ${WDK_ROOT}")
message(STATUS "   - Latest Version: ${WDK_LATEST_VERSION}")
message(STATUS "   - Available Versions: " ${WDK_ALL_VERSIONS})

set(WDK_ADDITIONAL_FLAGS_FILE "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/wdkflags.h")
file(WRITE ${WDK_ADDITIONAL_FLAGS_FILE} "#pragma runtime_checks(\"suc\", off)")

set(WDK_COMPILE_FLAGS
    "/Zp8" # set struct alignment
    "/GF"  # enable string pooling
    "/GR-" # disable RTTI
    "/Gz"  # __stdcall by default
    "/kernel"  # create kernel mode binary
    "/FIwarning.h" # disable warnings in WDK headers
    "/FI${WDK_ADDITIONAL_FLAGS_FILE}" # include file to disable RTC
    )

set(WDK_COMPILE_DEFINITIONS "WINNT=1")
set(WDK_COMPILE_DEFINITIONS_DEBUG "MSC_NOOPT;DEPRECATE_DDK_FUNCTIONS=1;DBG=1")

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    list(APPEND WDK_COMPILE_DEFINITIONS "_X86_=1;i386=1;STD_CALL")
    set(WDK_PLATFORM "x86")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    list(APPEND WDK_COMPILE_DEFINITIONS "_WIN64;_AMD64_;AMD64")
    set(WDK_PLATFORM "x64")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

string(CONCAT WDK_LINK_FLAGS
    "/MANIFEST:NO " #
    "/DRIVER " #
    "/OPT:REF " #
    "/INCREMENTAL:NO " #
    "/OPT:ICF " #
    "/SUBSYSTEM:NATIVE " #
    "/MERGE:_TEXT=.text;_PAGE=PAGE " #
    "/NODEFAULTLIB " # do not link default CRT
    "/SECTION:INIT,d " #
    "/VERSION:10.0 " #
    )

# Export

