
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

