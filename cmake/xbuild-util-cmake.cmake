
#[[
Compiler related helper functions
]]

# This function set common compiler options for Clang/MSVC
function(xbd_add_compile_option clangOption msvcOption)
    if(XBD_CL_CLANG)
        add_compile_options(${clangOption})
    elseif(XBD_CL_MSVC)
        add_compile_options(${msvcOption})
    else()
        message(FATAL_ERROR "Compiler is unsupported")
    endif()
endfunction()

# This is a workaround for add_compile_options not recognizing cancellation of msvc warnings.
# https://gitlab.kitware.com/cmake/cmake/-/issues/18736
function(xbd_remove_msvc_compiler_warnings target)
    if(MSVC)
        get_target_property(options ${target} COMPILE_OPTIONS)
        #message(STATUS "COMPILE_OPTIONS: ${options}")
        foreach(arg IN LISTS ARGN)
            string(REPLACE "${arg}" "" options "${options}")
        endforeach()
        set_target_properties(${target} PROPERTIES COMPILE_OPTIONS "${options}")
        #message(STATUS "COMPILE_OPTIONS: ${options}")
    endif()
endfunction()


# xbd_target_sources_parse_arguments()
# Helper macro for:
#    xbd_target_sources
# Arguments handled:
#   <SUBDIR> [subdir] prepends ${subdir} to all sources in the list, verifies that ${SUBDIR} exists
#   <VARNAME> [varname] to set ${varname} in parent scope to list of sources, to be used by later processing
#   <SOURCE_GROUP> [groupname] to automatically call source_group(${groupname}) on the list of sources
#   <SOURCES> [source1] [source2 ...]
# Note:
#    This must be a CMake macro (and not a function) to allow setting VARNAME in the parent scope
macro(xbd_target_sources_parse_arguments)
    set(target ${ARGV0})
    # Make local copy of ARGV becuase list(REMOVE_AT ARGV 0) in macro doesn't work in macro
    set(ARGV_COPY ${ARGV})
    # Note: when we upgrade to CMake 3.15, this can be changed to list(POP_FRONT ARGV_COPY target)
    list(REMOVE_AT ARGV_COPY 0)

    # Parse the Arguments
    cmake_parse_arguments(XBD_TARGET_SOURCES "" "VARNAME;SOURCE_GROUP;SUBDIR;DLL_EXPORT_HEADERS_PATH" "SOURCES" ${ARGV_COPY})

    # Handle SOURCES argument, ensure it is not empty
    set(SOURCES ${XBD_TARGET_SOURCES_SOURCES})
    if(NOT SOURCES)
        message(FATAL_ERROR "xbd_target_sources_parse_arguments() does not have SOURCES specified")
    endif()

    # Validate there are no remaining unparsed arguments
    if(NOT ${XBD_TARGET_SOURCES_UNPARSED_ARGUMENTS} EQUAL "")
        message(FATAL_ERROR "xbd_target_sources_parse_arguments() cannot handle extra arguments\nUNPARSED_ARGUMENTS=\"${XBD_TARGET_SOURCES_UNPARSED_ARGUMENTS}\"")
    endif()

    # Handle SUBDIR argument
    if(XBD_TARGET_SOURCES_SUBDIR)
        get_filename_component(SUBDIR "${XBD_TARGET_SOURCES_SUBDIR}"
            ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

        # Sanity check the SUBDIR argument actually exists in the current source directory
        if(NOT EXISTS "${SUBDIR}")
            message(FATAL_ERROR "SUBDIR=${SUBDIR} does not exist")
        endif()

        # prefix each source file w/ the SUBDIR string
        set(SOURCES_WITH_SUBDIR)
        foreach(ITEM IN LISTS SOURCES)
            list(APPEND SOURCES_WITH_SUBDIR "${SUBDIR}/${ITEM}")
        endforeach()
        set(SOURCES ${SOURCES_WITH_SUBDIR})
    endif()

    if(XBD_TARGET_SOURCES_DLL_EXPORT_HEADERS_PATH)
        get_target_property(bundle_exports ${target} MACOSX_BUNDLE_EXPORTS)
        if (NOT bundle_exports)
            set(bundle_exports)
        endif()
        list(APPEND bundle_exports ${SOURCES})
        set_target_properties(${target} PROPERTIES MACOSX_BUNDLE_EXPORTS "${bundle_exports}")

        foreach(source IN LISTS SOURCES)
            set_property(TARGET ${target} APPEND PROPERTY "DLL_EXPORT_HEADERS_PATH:${source}" "${XBD_TARGET_SOURCES_DLL_EXPORT_HEADERS_PATH}")
        endforeach()
    endif()

    # Handle VARNAME argument by setting ${VARNAME}=${SOURCES} in the enclosing/parent scope
    if(XBD_TARGET_SOURCES_VARNAME)
        set("${XBD_TARGET_SOURCES_VARNAME}" ${SOURCES} PARENT_SCOPE)
    endif()

    # Handle SOURCE_GROUP argument by placing transformed SOURCES into the specified source group
    if(XBD_TARGET_SOURCES_SOURCE_GROUP)
        source_group("${XBD_TARGET_SOURCES_SOURCE_GROUP}" FILES ${SOURCES})
    endif()
endmacro()

# xbd_target_sources(target <list of source files>)
#   refer to xbd_target_sources_parse_arguments for arguments documentations
function(xbd_target_sources target)
    xbd_target_sources_parse_arguments(${ARGV})
    target_sources(${target} PRIVATE ${SOURCES})
endfunction()

function(xbd_add_executable target)

    cmake_parse_arguments(ADD_EXECUTABLE "NO_MANIFEST" "MANIFEST_FILE" "" ${ARGN})
    add_executable(${target} ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})

    # Variables used to configure target_properties.py
    set(TARGET_GENERATOR ${CMAKE_GENERATOR})
    set(TARGET_NAME ${ARGV0})
    set(TARGET_SANITIZER ${XBD_OPT_USE_SANITIZER})
    set(TARGET_CONFIGURATION ${CMAKE_BUILD_TYPE})
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(TARGET_ARCHITECTURE "X64")
    else()
        set(TARGET_ARCHITECTURE "X86")
    endif()
    set(TARGET_CMDLINE_PARAMS "")

    # Add Sources.cmake to target if it exists.
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    endif()

    # By default, put 'src' in Include list
    target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")

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
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
      endif()
    endif()
endfunction()

# This function set properties for Widnows kernel mode target
function (xbd_set_kernel_mode target)
    # Windows Only
    if (WIN32)
        add_compile_definitions(XBD_WINDOWS_KERNEL_MODE)
        get_target_property(target_type ${target} TYPE)
        if (target_type STREQUAL "SHARED")
            # Target is a Windows Driver
			add_compile_options(MT)
        elseif (target_type STREQUAL "STATIC")
            # Target is a Windows Kernel Library
			add_compile_options(MT)
        else()
            message(FATAL_ERROR "xbd_set_kernel_mode does not support target type")
        endif()
        set_target_properties(${target} PROPERTIES EXCLUDE_FROM_ALL TRUE)
    else()
        message(FATAL_ERROR "xbd_set_kernel_mode() only supports Windows platform")
    endif()
endfunction()

# This function add a Widnows kernel Mode library
function (xbd_add_kernel_library target)
    # Windows Only
    if (WIN32)
        add_library(${target} STATIC)
        xbd_set_kernel_mode(${target})
        set_target_properties(${target} PROPERTIES EXCLUDE_FROM_ALL TRUE)
        set_target_properties(${target} PROPERTIES FOLDER libs)
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/include")
            target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
        endif()
		# By default, put 'src' in Include list
		target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")
		# Add Sources.cmake to target if it exists.
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
            target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        endif()
    else()
        message(FATAL_ERROR "xbd_add_kernel_library() only supports Windows platform")
    endif()
endfunction()

# This function add a Widnows kernel Mode driver
function (xbd_add_kernel_driver target)
    # Windows Only
    if (WIN32)
        add_library(${target} SHARED)
        xbd_set_kernel_mode(${target})
        set_target_properties(${target} PROPERTIES FOLDER drivers)
        set_target_properties(${target} PROPERTIES SUFFIX ".sys")
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/include")
            target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
        endif()
		# By default, put 'src' in Include list
		target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")
		# Add Sources.cmake to target if it exists.
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
            target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        endif()
    else()
        message(FATAL_ERROR "xbd_add_kernel_driver() only supports Windows platform")
    endif()
endfunction()