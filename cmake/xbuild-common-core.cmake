#####################################
#       XBUILD CMAKE FUNCTIONS      #
#####################################

#
#  Add Target
#
function(xbuild_add_executable target)

    cmake_parse_arguments(ADD_EXECUTABLE "NO_MANIFEST" "MANIFEST_FILE" "" ${ARGN})
    add_executable(${target} ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})
    
    # Set default LINKER_LANGUAGE to C++
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)

    # Variables used to configure target_properties.py
    set(TARGET_GENERATOR ${CMAKE_GENERATOR})
    set(TARGET_NAME ${ARGV0})
    set(TARGET_CONFIGURATION ${CMAKE_BUILD_TYPE})
    
    # Add Sources.cmake to target if it exists.
    message("Looking for source file: '${CMAKE_CURRENT_LIST_DIR}/Sources.cmake'")
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    else()
        message("  - Not exist")
    endif()
endfunction()

function(xbuild_add_static_library target)

    add_library(${target} STATIC ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})
    
    # Set default LINKER_LANGUAGE to C++
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)

    # Variables used to configure target_properties.py
    set(TARGET_GENERATOR ${CMAKE_GENERATOR})
    set(TARGET_NAME ${ARGV0})
    set(TARGET_CONFIGURATION ${CMAKE_BUILD_TYPE})
    
    # Add Sources.cmake to target if it exists.
    message("Looking for source file: '${CMAKE_CURRENT_LIST_DIR}/Sources.cmake'")
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    else()
        message("  - Not exist")
    endif()
endfunction()

function(xbuild_add_shared_library target)

    add_library(${target} SHARED ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})
    
    # Set default LINKER_LANGUAGE to C++
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)

    # Variables used to configure target_properties.py
    set(TARGET_GENERATOR ${CMAKE_GENERATOR})
    set(TARGET_NAME ${ARGV0})
    set(TARGET_CONFIGURATION ${CMAKE_BUILD_TYPE})
    
    # Add Sources.cmake to target if it exists.
    message("Looking for source file: '${CMAKE_CURRENT_LIST_DIR}/Sources.cmake'")
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    else()
        message("  - Not exist")
    endif()
endfunction()

function(xbuild_add_windows_driver target)

    add_library(${target} SHARED ${ADD_EXECUTABLE_UNPARSED_ARGUMENTS})
    
    # Set default LINKER_LANGUAGE to C
    set_target_properties(${target} PROPERTIES LINKER_LANGUAGE C)

    # Variables used to configure target_properties.py
    set(TARGET_GENERATOR ${CMAKE_GENERATOR})
    set(TARGET_NAME ${ARGV0})
    set(TARGET_CONFIGURATION ${CMAKE_BUILD_TYPE})

    # Add Sources.cmake to target if it exists.
    message("Looking for source file: '${CMAKE_CURRENT_LIST_DIR}/Sources.cmake'")
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/Sources.cmake")
        target_sources(${target} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        include (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)
        message("  - Found (${CMAKE_CURRENT_LIST_DIR}/Sources.cmake)")
    else()
        message("  - Not exist")
    endif()
endfunction()

#
#  Add Options
#
function(xbuild_option_string)
    # https://cmake.org/cmake/help/v3.18/command/cmake_parse_arguments.html
    cmake_parse_arguments(PARSE_ARGV 0 XBUILD_STRING_OPT "TOLOWER;TO_CMAKE_PATH" "NAME;DESCRIPTION;DEFAULT" "CHOICES")

    # First make sure all required arguments were actually given
    foreach (required_arg NAME DESCRIPTION DEFAULT)
        if (NOT DEFINED XBUILD_STRING_OPT_${required_arg})
            list(APPEND MISSING_REQUIRED_ARGS ${required_arg})
        endif()
    endforeach()
    if (DEFINED MISSING_REQUIRED_ARGS)
        message(FATAL_ERROR "xbuild_option_string() missing required args ${MISSING_REQUIRED_ARGS}")
    endif()
    if (DEFINED XBUILD_STRING_OPT_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "xbuild_option_string() has unparsed args=\"${XBUILD_STRING_OPT_UNPARSED_ARGUMENTS}\"")
    endif()

    # First calculate the help string for the cache variable.  If there are choices, append them to the help string.
    if(DEFINED XBUILD_STRING_OPT_CHOICES)
        string(REPLACE ";" ", " XBUILD_STRING_OPT_CHOICES_COMMA "${XBUILD_STRING_OPT_CHOICES}")
        set(CACHE_HELP_STRING "${XBUILD_STRING_OPT_DESCRIPTION}: {${XBUILD_STRING_OPT_CHOICES_COMMA}}")
    else()
        set(CACHE_HELP_STRING ${XBUILD_STRING_OPT_DESCRIPTION})
    endif()

    # Next define the cache variable using the default value.
    set(${XBUILD_STRING_OPT_NAME} "${XBUILD_STRING_OPT_DEFAULT}" CACHE STRING ${XBUILD_STRING_OPT_DESCRIPTION})

    # If the caller passed TOLOWER, force update the cache variable with a lowercase version of itself.
    if (XBUILD_STRING_OPT_TOLOWER)
        string(TOLOWER ${${XBUILD_STRING_OPT_NAME}} OPTION_VALUE_LOWER)

        set(${XBUILD_STRING_OPT_NAME} "${OPTION_VALUE_LOWER}" CACHE STRING ${XBUILD_STRING_OPT_DESCRIPTION} FORCE)
    endif()

    # If the caller passed TO_CMAKE_PATH, run it and force set the result.
    if (XBUILD_STRING_OPT_TO_CMAKE_PATH)
        file(TO_CMAKE_PATH "${${XBUILD_STRING_OPT_NAME}}" OPTION_VALUE_TO_CMAKE_PATH)

        set(${XBUILD_STRING_OPT_NAME} "${OPTION_VALUE_TO_CMAKE_PATH}" CACHE PATH ${XBUILD_STRING_OPT_DESCRIPTION} FORCE)
    endif()

    # Finally, if we had a list of choices passed in, validate the final value of the cache variable.
    if(DEFINED XBUILD_STRING_OPT_CHOICES)
        if (XBUILD_STRING_OPT_TOLOWER)
            string(TOLOWER "${XBUILD_STRING_OPT_CHOICES}" CASE_ADJUSTED_CHOICES)
            string(TOLOWER "${${XBUILD_STRING_OPT_NAME}}" CASE_ADJUSTED_OPTION_VALUE)
        else()
            set(CASE_ADJUSTED_OPTION_VALUE "${${XBUILD_STRING_OPT_NAME}}")
            set(CASE_ADJUSTED_CHOICES "${XBUILD_STRING_OPT_CHOICES}")
        endif()

        if(NOT ("${CASE_ADJUSTED_OPTION_VALUE}" IN_LIST XBUILD_STRING_OPT_CHOICES))
            message(FATAL_ERROR "Option ${XBUILD_STRING_OPT_NAME} contains invalid value '${${XBUILD_STRING_OPT_NAME}}': Expected one of {${XBUILD_STRING_OPT_CHOICES_COMMA}}")
        endif()
    endif()

    message(STATUS "XBuild Option: string ${XBUILD_STRING_OPT_NAME} = ${${XBUILD_STRING_OPT_NAME}}")
endfunction()

function(xbuild_option_bool)
    cmake_parse_arguments(PARSE_ARGV 0 XBUILD_BOOL_OPT "DEFINE_PREPROCESSOR" "NAME;DESCRIPTION;DEFAULT" "MAKE_AVAILABLE_IF")

    foreach (required_arg NAME DESCRIPTION DEFAULT)
        if (NOT DEFINED XBUILD_BOOL_OPT_${required_arg})
            list(APPEND MISSING_REQUIRED_ARGS ${required_arg})
        endif()
    endforeach()
    if (DEFINED MISSING_REQUIRED_ARGS)
        message(FATAL_ERROR "xbuild_option_bool() missing required args ${MISSING_REQUIRED_ARGS}")
    endif()
    if (DEFINED XBUILD_BOOL_OPT_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "xbuild_option_bool() has unparsed args=\"${XBUILD_BOOL_OPT_UNPARSED_ARGUMENTS}\"")
    endif()

    set(IS_CONDITIONAL_OPTION OFF)
    set(CONDITIONAL_OPTION_MATCHED_RULE OFF)
    if (DEFINED XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF)
        set(IS_CONDITIONAL_OPTION ON)

        while(XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF)
            list(LENGTH XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF LIST_LEN)
            if (${LIST_LEN} LESS 2)
                message(FATAL_ERROR "Expected an even number of list items.  Received '${XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF}'")
            endif()

            list(GET XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF 0 CONDITION)
            list(GET XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF 1 VALUE)
            list(REMOVE_AT XBUILD_BOOL_OPT_MAKE_AVAILABLE_IF 0 1)

            # Actually evaluate the condition that was passed in as a string.  If it was true, this is the first rule that
            # matched, so set the default value and break out of the rule-evaluation loop.
            set(CONDITION_AS_LIST ${CONDITION})
            string(REGEX REPLACE "\\(" " ( " CONDITION_AS_LIST "${CONDITION_AS_LIST}")
            string(REGEX REPLACE "\\)" " ) " CONDITION_AS_LIST "${CONDITION_AS_LIST}")
            string(REGEX REPLACE " +" ";" CONDITION_AS_LIST "${CONDITION_AS_LIST}")
            if (${CONDITION_AS_LIST})
                set(CONDITIONAL_OPTION_MATCHED_RULE ON)
                set(FINAL_DEFAULT_VALUE ${VALUE})
                break()
            endif()
        endwhile()
    endif()

    if (NOT DEFINED FINAL_DEFAULT_VALUE)
        set(FINAL_DEFAULT_VALUE ${XBUILD_BOOL_OPT_DEFAULT})
    endif()

    option(${XBUILD_BOOL_OPT_NAME} "${XBUILD_BOOL_OPT_DESCRIPTION}" ${FINAL_DEFAULT_VALUE})

    if (IS_CONDITIONAL_OPTION AND NOT CONDITIONAL_OPTION_MATCHED_RULE)
        set(${XBUILD_BOOL_OPT_NAME} ${FINAL_DEFAULT_VALUE} CACHE STRING "${XBUILD_BOOL_OPT_DESCRIPTION}" FORCE)
    endif()

    set(FINAL_OPTION_VALUE ${${XBUILD_BOOL_OPT_NAME}})
    message(STATUS "XBuild Option: bool ${XBUILD_BOOL_OPT_NAME} = ${FINAL_OPTION_VALUE}")

    if (${XBUILD_BOOL_OPT_DEFINE_PREPROCESSOR} AND ${FINAL_OPTION_VALUE})
        add_definitions(-D${XBUILD_BOOL_OPT_NAME})
    endif()
endfunction()
