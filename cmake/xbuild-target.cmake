include_guard(DIRECTORY)

#[[
    Common Targets
        - xbd_add_executable
        - xbd_add_library
]]

function(xbd_add_executable target)
    # Enable message context
    set(CMAKE_MESSAGE_CONTEXT "Target.${target}")
    set(CMAKE_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" PARENT_SCOPE)
    set(TARGET_NAME ${ARGV0})

    message(STATUS "Add executable: ${target}")
    cmake_parse_arguments(ADD_EXECUTABLE "NO_MANIFEST" "MANIFEST_FILE;WINVER;SUBSYSTEM" "" ${ARGN})
    add_executable(${target} ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})

    if (ADD_EXECUTABLE_WINVER)
        set(TARGET_WINVER "${ADD_EXECUTABLE_WINVER}")
        set(TARGET_NTDDI_VERSION "${WADD_EXECUTABLE_WINVER}0000")
    else()
        set(TARGET_WINVER "${WINDOWS_VERSION_DEFAULT}")
        set(TARGET_NTDDI_VERSION "${WINDOWS_VERSION_DEFAULT}0000")
    endif()

    set(EXECUTABLE_LINK_FLAGS "${XBD_DEFAULT_LINK_FLAGS}")
    if (ADD_EXECUTABLE_SUBSYSTEM STREQUAL "CONSOLE")
        string(REPLACE "/SUBSYSTEM:WINDOWS" "/SUBSYSTEM:CONSOLE" EXECUTABLE_LINK_FLAGS "${EXECUTABLE_LINK_FLAGS}")
    endif()

    # Set compile options and definitions
    set_target_properties(${target} PROPERTIES
        FOLDER app
        COMPILE_OPTIONS "${XBD_DEFAULT_COMPILE_OPTIONS}"
        COMPILE_DEFINITIONS "${XBD_DEFAULT_COMPILE_DEFINITIONS};_WIN32_WINNT=${TARGET_WINVER};NTDDI_VERSION=${TARGET_WINVER}0000"
        LINK_FLAGS "${EXECUTABLE_LINK_FLAGS}"
    )
    
    # Variables used to configure target_properties.py
    # By default, put 'src' in Include list
    target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")
    # Add Sources.cmake to target if it exists.
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        message(STATUS "Found sources (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
    endif()

    # Add manifest file for Windows Executable
    if(WIN32)
        if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/src/${TARGET_NAME}.manifest")
            target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src/${TARGET_NAME}.manifest)
        endif()
    endif()
endfunction()

# xbd_add_library()
#   Wrapper function for CMake's add_library()
#   Provides additional functionality:
#     a. If the only argument is the target name, e.g. xbd_add_library(Foo)
#        a STATIC library is assumed with empty sources.
#        Adding sources should then be done via:
#            xbd_target_sources(<target> ...)
#        refer to article: https://crascit.com/2016/01/31/enhanced-source-file-handling-with-target_sources/ (archived at http://archive.is/wip/BEVmb)
#
#     b. If RFC-ST0001 compliant library public include sub-dir exists
#          (e.g. Foo/include/Foo)
#        then it will be added to the target's PUBLIC include directories
#
#     c. The specified target is not included in the 'all' target by default.
#        The target _will_ be built if another target is dependant upon the target.
#
#     d. The specified target will be added to "Libs" folder for IDEs such as VS or XCode
#
function (xbd_add_library target)
    # Enable message context
    set(CMAKE_MESSAGE_CONTEXT "Target.${target}")
    set(CMAKE_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" PARENT_SCOPE)
    
    message(STATUS "Add library: ${target}")
    # Handle single argument case specially
    set(args STATIC)
    if (ARGC GREATER 1)
        # otherwise pass flags on unmodified
        set(args ${ARGN})
    endif()
    add_library(${target} ${args})

    set_target_properties(${target}
        PROPERTIES
        EXCLUDE_FROM_ALL TRUE
        FOLDER libs
        COMPILE_OPTIONS "${XBD_DEFAULT_COMPILE_OPTIONS}"
        COMPILE_DEFINITIONS "${XBD_DEFAULT_COMPILE_DEFINITIONS};_WIN32_WINNT=${TARGET_WINVER};NTDDI_VERSION=${TARGET_WINVER}0000"
        LINK_FLAGS "${XBD_DEFAULT_LINK_FLAGS}"
    )

    get_target_property(target_type ${target} TYPE)
    set(header_visibility PUBLIC)
    if (target_type STREQUAL "INTERFACE_LIBRARY")
        set(header_visibility INTERFACE)
    endif()
    
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/include")
        target_include_directories(${target} ${header_visibility} ${CMAKE_CURRENT_LIST_DIR}/include)
    endif()

    if (NOT target_type STREQUAL "INTERFACE_LIBRARY")
        target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src)
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
            message(STATUS "Found sources (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
            target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
            include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        endif()
    endif()
endfunction()

#[[
    Windows Only Targets
        - xbd_add_kernel_library
        - xbd_add_kernel_driver
]]

# Function `xbd_add_kernel_library` adds a Widnows kernel Mode Library target
# xbd_add_kernel_library TARGETNAME [KMDF=] [WINVER=] ...
function (xbd_add_kernel_library target)
    # Enable message context
    set(CMAKE_MESSAGE_CONTEXT "Target.${target}")
    set(CMAKE_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" PARENT_SCOPE)
    
    message(STATUS "Add Windows Kernel Library: ${target}")
    # Windows Only
    if (NOT WIN32)
        message(FATAL_ERROR "xbd_add_kernel_library() only supports Windows platform")
        return()
    endif()

    # Ensure WDK is installed
    if (NOT WDK_FOUND)
        message(FATAL_ERROR "WDK is not installed, please download and install Windows Driver Kit (WDK) from here:\nhttps://learn.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk")
        return()
    endif()

    # Add target
    cmake_parse_arguments(WDK "" "KMDF;WINVER;NTDDI_VERSION" "" ${ARGN})
    list(REMOVE_ITEM ARGN "STATIC") # Ensure no static keyword
    list(REMOVE_ITEM ARGN "SHARED") # Ensure no shared keyword
    add_library(${target} STATIC ${WDK_UNPARSED_ARGUMENTS})

    if (WDK_WINVER)
        set(TARGET_WINVER "${WDK_WINVER}")
        set(TARGET_NTDDI_VERSION "${WDK_WINVER}0000")
    else()
        set(TARGET_WINVER "${WINDOWS_VERSION_DEFAULT}")
        set(TARGET_NTDDI_VERSION "${WINDOWS_VERSION_DEFAULT}0000")
    endif()

    # Ensure we have valid WDK version
    if (WDK_VERSION)
        list(FIND WDK_ALL_VERSIONS "${WDK_VERSION}" WDK_VER_INDEX)
        if (WDK_VER_INDEX EQUAL -1)
            message(WARNING "WDK version (${WDK_VERSION}) is not installed, use default WDK version (${WDK_LATEST_VERSION})")
            set(WDK_VERSION "${WDK_LATEST_VERSION}")
        endif()
    else()
        set(WDK_VERSION "${WDK_LATEST_VERSION}")
    endif()
    set(WDK_VERSION "${WDK_VERSION}" PARENT_SCOPE)

    # Set compile options and definitions
    set_target_properties(${target} PROPERTIES EXCLUDE_FROM_ALL TRUE
        FOLDER libs
        VS_CONFIGURATION_TYPE "Driver"
        VS_PLATFORM_TOOLSET "WindowsKernelModeDriver10.0"
        COMPILE_OPTIONS "${WDK_DEFAULT_COMPILE_OPTIONS}"
        COMPILE_DEFINITIONS "${WDK_DEFAULT_COMPILE_DEFINITIONS};$<$<CONFIG:Debug>:${WDK_DEFAULT_COMPILE_DEFINITIONS_DEBUG}>;_WIN32_WINNT=${TARGET_WINVER};NTDDI_VERSION=${TARGET_WINVER}0000;_NT_TARGET_VERSION=${TARGET_WINVER}"
    )

    # Set include directories
    #   - Current dirs
    target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/include")
        target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
    endif()
    #   - WDK dirs
    target_include_directories(${target} SYSTEM PRIVATE
        "${WDK_ROOT}/Include/${WDK_VERSION}/shared"
        "${WDK_ROOT}/Include/${WDK_VERSION}/km"
        "${WDK_ROOT}/Include/${WDK_VERSION}/km/crt"
        )
    if(DEFINED WDK_KMDF)
        target_include_directories(${target} SYSTEM PRIVATE "${WDK_ROOT}/Include/wdf/kmdf/${WDK_KMDF}")
    endif()

	# Add Sources.cmake to target if it exists.
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message(STATUS "Found sources (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    endif()
endfunction()

# Function `xbd_add_kernel_library` adds a Widnows kernel Mode Driver target
# xbd_add_kernel_library TARGETNAME [KMDF=] [WINVER=] ...
function (xbd_add_kernel_driver target)
    # Enable message context
    set(CMAKE_MESSAGE_CONTEXT "Target.${target}")
    set(CMAKE_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" PARENT_SCOPE)

    message(STATUS "Add Windows Kernel Driver: ${target}")
    # Windows Only
    if (NOT WIN32)
        message(FATAL_ERROR "xbd_add_kernel_driver() only supports Windows platform")
        return()
    endif()

    # Ensure WDK is installed
    if (NOT WDK_FOUND)
        message(FATAL_ERROR "WDK is not installed, please download and install Windows Driver Kit (WDK) from here:\nhttps://learn.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk")
        return()
    endif()

    # Add target
    cmake_parse_arguments(WDK "" "KMDF;WINVER" "" ${ARGN})
    add_executable(${target} ${WDK_UNPARSED_ARGUMENTS})

    if (WDK_WINVER)
        set(TARGET_WINVER "${WDK_WINVER}")
        set(TARGET_NTDDI_VERSION "${WDK_WINVER}0000")
    else()
        set(TARGET_WINVER "${WINDOWS_VERSION_DEFAULT}")
        set(TARGET_NTDDI_VERSION "${WINDOWS_VERSION_DEFAULT}0000")
    endif()

    # Ensure we have valid WDK version
    if (WDK_VERSION)
        list(FIND WDK_ALL_VERSIONS "${WDK_VERSION}" WDK_VER_INDEX)
        if (WDK_VER_INDEX EQUAL -1)
            message(WARNING "WDK version (${WDK_VERSION}) is not installed, use default WDK version (${WDK_LATEST_VERSION})")
            set(WDK_VERSION "${WDK_LATEST_VERSION}")
        endif()
    else()
        set(WDK_VERSION "${WDK_LATEST_VERSION}")
    endif()
    set(WDK_VERSION "${WDK_VERSION}" PARENT_SCOPE)

    # Set compile options and definitions
    set_target_properties(${target} PROPERTIES EXCLUDE_FROM_ALL TRUE
        FOLDER driver
        SUFFIX ".sys"
        VS_CONFIGURATION_TYPE "Driver"
        VS_PLATFORM_TOOLSET "WindowsKernelModeDriver10.0"
        COMPILE_OPTIONS "${WDK_DEFAULT_COMPILE_OPTIONS}"
        COMPILE_DEFINITIONS "${WDK_DEFAULT_COMPILE_DEFINITIONS};$<$<CONFIG:Debug>:${WDK_DEFAULT_COMPILE_DEFINITIONS_DEBUG}>;_WIN32_WINNT=${TARGET_WINVER};NTDDI_VERSION=${TARGET_WINVER}0000;_NT_TARGET_VERSION=${TARGET_WINVER}"
        LINK_FLAGS "${WDK_DEFAULT_LINK_FLAGS}"
    )

    # Set directories
    #   - Include: current dirs
    target_include_directories(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/include")
        target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
    endif()
    #   - Include: WDK dirs
    target_include_directories(${target} SYSTEM
        PRIVATE "${WDK_ROOT}/Include/${WDK_VERSION}/shared"
        PRIVATE "${WDK_ROOT}/Include/${WDK_VERSION}/km"
        PRIVATE "${WDK_ROOT}/Include/${WDK_VERSION}/km/crt"
        )
    #   - Link: WDK dirs
    target_link_directories(${target} PRIVATE
        "${WDK_ROOT}/Lib/${WDK_VERSION}/${WDK_PLATFORM}/km"
    )

    # Add default libraries
    set_property(TARGET ${target} PROPERTY LINK_LIBRARIES ${WDK_DEFAULT_LIBRARIES})
    
    #check_cxx_compiler_flag(-Qspectre HAS_QSPECTRE)
    #if (HAS_QSPECTRE)
    #    message(STATUS "/Qspectre is detected in driver target")
    #endif()

    if(DEFINED WDK_KMDF)
        target_include_directories(${target} SYSTEM PRIVATE "${WDK_ROOT}/Include/wdf/kmdf/${WDK_KMDF}")
        target_link_libraries(${target}
            "${WDK_ROOT}/Lib/wdf/kmdf/${WDK_PLATFORM}/${WDK_KMDF}/WdfDriverEntry.lib"
            "${WDK_ROOT}/Lib/wdf/kmdf/${WDK_PLATFORM}/${WDK_KMDF}/WdfLdr.lib"
            )
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "/ENTRY:FxDriverEntry@8")
        elseif(CMAKE_SIZEOF_VOID_P  EQUAL 8)
            set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "/ENTRY:FxDriverEntry")
        endif()
    else()
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "/ENTRY:GsDriverEntry@8")
        elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS "/ENTRY:GsDriverEntry")
        endif()
    endif()
    
    # Disable QSPECTRE
    #get_property(CompileOptions TARGET ${target} PROPERTY COMPILE_OPTIONS)
    #message(STATUS "CompileOptions: ${CompileOptions}")
    #get_property(CMakeCFlags TARGET ${target} PROPERTY CMAKE_C_FLAGS)
    #message(STATUS "CMakeCFlags: ${CMakeCFlags}")
    #get_property(CMakeCxxFlags TARGET ${target} PROPERTY CMAKE_CXX_FLAGS)
    #message(STATUS "CMakeCxxFlags: ${CMakeCxxFlags}")
    #get_property(CMakeCInitLibs TARGET ${target} PROPERTY CMAKE_C_STANDARD_LIBRARIES_INIT)
    #message(STATUS "CMakeCInitLibs: ${CMakeCInitLibs}")
    #get_property(CMakeCxxInitLibs TARGET ${target} PROPERTY CMAKE_CXX_STANDARD_LIBRARIES_INIT)
    #message(STATUS "CMakeCxxInitLibs: ${CMakeCxxInitLibs}")
    #get_property(CMakeStaticLinkFlags TARGET ${target} PROPERTY LINK_FLAGS)
    #message(STATUS "CMakeStaticLinkFlags: ${CMakeStaticLinkFlags}")

	# Add Sources.cmake to target if it exists.
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message(STATUS "Found sources (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    endif()
endfunction()