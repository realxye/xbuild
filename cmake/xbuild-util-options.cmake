
#[[
Options helper functions
]]

# Functions defined in this file must be truly generic.  They must depend on no other Roblox specific helper functions
# or variables, and they cannot include any other Roblox CMake files.  They must be useful to an arbitrary CMake project
# that is completely unrelated to Roblox.

# Exposes a CMake option / cache variable whose value is a string.
# Optional arguments:
#   NAME <name>         - Required. The name of the option (e.g. passing -D<name> to CMake will set this option)
#   DESCRIPTION <desc>  - Required. A meaningful description of the option, to help users understand its purpose.
#   CHOICES             - Optional: a list of valid values for the option.  The function does validation to make sure that the given
#                                   value matches one of the choices, and will fail otherwise.
#   DEFAULT <value>     - Required: a default value for the option, which will be used if no value if given.
#   TOLOWER             - Optional: Lowercases the result to facilitate case insensitive string comparisons.  When CHOICES are given
#                                   performs validation using case-insensitive string compare.
#   TO_CMAKE_PATH       - Optional: Runs file(TO_CMAKE_PATH) on the result.
#
function(xbd_option_string)
    # https://cmake.org/cmake/help/v3.18/command/cmake_parse_arguments.html
    cmake_parse_arguments(PARSE_ARGV 0 XBD_STRING_OPT "TOLOWER;TO_CMAKE_PATH" "NAME;DESCRIPTION;DEFAULT" "CHOICES")

    # First make sure all required arguments were actually given
    foreach (required_arg IN ITEMS NAME DESCRIPTION DEFAULT)
        if (NOT DEFINED XBD_STRING_OPT_${required_arg})
            list(APPEND MISSING_REQUIRED_ARGS ${required_arg})
        endif()
    endforeach()
    if (DEFINED MISSING_REQUIRED_ARGS)
        message(FATAL_ERROR "xbd_option_string() missing required args ${MISSING_REQUIRED_ARGS}")
    endif()
    if (DEFINED XBD_STRING_OPT_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "xbd_option_string() has unparsed args=\"${XBD_STRING_OPT_UNPARSED_ARGUMENTS}\"")
    endif()

    # First calculate the help string for the cache variable.  If there are choices, append them to the help string.
    if(DEFINED XBD_STRING_OPT_CHOICES)
        string(REPLACE ";" ", " XBD_STRING_OPT_CHOICES_COMMA "${XBD_STRING_OPT_CHOICES}")
        set(CACHE_HELP_STRING "${XBD_STRING_OPT_DESCRIPTION}: {${XBD_STRING_OPT_CHOICES_COMMA}}")
    else()
        set(CACHE_HELP_STRING ${XBD_STRING_OPT_DESCRIPTION})
    endif()

    # Next define the cache variable using the default value.
    set(${XBD_STRING_OPT_NAME} "${XBD_STRING_OPT_DEFAULT}" CACHE STRING ${XBD_STRING_OPT_DESCRIPTION})

    # If the caller passed TOLOWER, force update the cache variable with a lowercase version of itself.
    if (XBD_STRING_OPT_TOLOWER)
        string(TOLOWER ${${XBD_STRING_OPT_NAME}} OPTION_VALUE_LOWER)
        set(${XBD_STRING_OPT_NAME} "${OPTION_VALUE_LOWER}" CACHE STRING ${XBD_STRING_OPT_DESCRIPTION} FORCE)
    endif()

    # If the caller passed TO_CMAKE_PATH, run it and force set the result.
    if (XBD_STRING_OPT_TO_CMAKE_PATH)
        file(TO_CMAKE_PATH "${${XBD_STRING_OPT_NAME}}" OPTION_VALUE_TO_CMAKE_PATH)
        set(${XBD_STRING_OPT_NAME} "${OPTION_VALUE_TO_CMAKE_PATH}" CACHE PATH ${XBD_STRING_OPT_DESCRIPTION} FORCE)
    endif()

    # Finally, if we had a list of choices passed in, validate the final value of the cache variable.
    if(DEFINED XBD_STRING_OPT_CHOICES)
        if (XBD_STRING_OPT_TOLOWER)
            string(TOLOWER "${XBD_STRING_OPT_CHOICES}" CASE_ADJUSTED_CHOICES)
            string(TOLOWER "${${XBD_STRING_OPT_NAME}}" CASE_ADJUSTED_OPTION_VALUE)
        else()
            set(CASE_ADJUSTED_OPTION_VALUE "${${XBD_STRING_OPT_NAME}}")
            set(CASE_ADJUSTED_CHOICES "${XBD_STRING_OPT_CHOICES}")
        endif()

        if(NOT ("${CASE_ADJUSTED_OPTION_VALUE}" IN_LIST XBD_STRING_OPT_CHOICES))
            message(FATAL_ERROR "Option ${XBD_STRING_OPT_NAME} contains invalid value '${${XBD_STRING_OPT_NAME}}': Expected one of {${XBD_STRING_OPT_CHOICES_COMMA}}")
        endif()
    endif()

    message(STATUS "Roblox Option: string ${XBD_STRING_OPT_NAME} = ${${XBD_STRING_OPT_NAME}}")
endfunction()

# Exposes a CMake option / cache variable whose value is a boolean.  This offers additional functionality over option().  Specifically:
#   1. If desired, it can automatically define a pre-processor variable in all source files that indicate that the option is on.
#      This allows us to propagate information about option configuration from the build system to the code.
#   2. It supports conditionally visible options.  Specifically, you might only want an option to be presented to the user if some
#      other condition is true, and when the condition is not true the option gets a default value.
#
#  Parameters:
#   NAME <name>         - Required. The name of the option (e.g. passing -D<name> to CMake will set this option)
#   DESCRIPTION <desc>  - Required. A meaningful description of the option, to help users understand its purpose.
#   MAKE_AVAILABLE_IF   - Optional. A set of rules that are processed in order.  Once a condition is found which evaluates to true, 
#      <cond1> <value1>             the corresponding value is chosen as the default for this option, to be used when populating the
#      <cond2> <value2>             cache for the first time.
#      ...
#   DEFAULT ON|OFF      - Required. If the MAKE_AVAILABLE_IF parameter is not passed, or if none of the conditions evaluate to true, this
#                                   value is used when populating the cache for the first time.
#   DEFINE_PROCESSOR    - Optional. If given, all source files will have have the preprocessor definition <name> available during compilation.
function(xbd_option_bool)
    cmake_parse_arguments(PARSE_ARGV 0 XBD_BOOL_OPT "DEFINE_PREPROCESSOR" "NAME;DESCRIPTION;DEFAULT" "MAKE_AVAILABLE_IF")

    foreach (required_arg IN ITEMS NAME DESCRIPTION DEFAULT)
        if (NOT DEFINED XBD_BOOL_OPT_${required_arg})
            list(APPEND MISSING_REQUIRED_ARGS ${required_arg})
        endif()
    endforeach()
    if (DEFINED MISSING_REQUIRED_ARGS)
        message(FATAL_ERROR "xbd_option_bool() missing required args ${MISSING_REQUIRED_ARGS}")
    endif()
    if (DEFINED XBD_BOOL_OPT_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "xbd_option_bool() has unparsed args=\"${XBD_BOOL_OPT_UNPARSED_ARGUMENTS}\"")
    endif()

    set(IS_CONDITIONAL_OPTION OFF)
    set(CONDITIONAL_OPTION_MATCHED_RULE OFF)
    if (DEFINED XBD_BOOL_OPT_MAKE_AVAILABLE_IF)
        set(IS_CONDITIONAL_OPTION ON)

        while(XBD_BOOL_OPT_MAKE_AVAILABLE_IF)
            list(LENGTH XBD_BOOL_OPT_MAKE_AVAILABLE_IF LIST_LEN)
            if (${LIST_LEN} LESS 2)
                message(FATAL_ERROR "Expected an even number of list items.  Received '${XBD_BOOL_OPT_MAKE_AVAILABLE_IF}'")
            endif()

            list(GET XBD_BOOL_OPT_MAKE_AVAILABLE_IF 0 CONDITION)
            list(GET XBD_BOOL_OPT_MAKE_AVAILABLE_IF 1 VALUE)
            list(REMOVE_AT XBD_BOOL_OPT_MAKE_AVAILABLE_IF 0 1)

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
        set(FINAL_DEFAULT_VALUE ${XBD_BOOL_OPT_DEFAULT})
    endif()

    option(${XBD_BOOL_OPT_NAME} "${XBD_BOOL_OPT_DESCRIPTION}" ${FINAL_DEFAULT_VALUE})

    if (IS_CONDITIONAL_OPTION AND NOT CONDITIONAL_OPTION_MATCHED_RULE)
        set(${XBD_BOOL_OPT_NAME} ${FINAL_DEFAULT_VALUE} CACHE STRING "${XBD_BOOL_OPT_DESCRIPTION}" FORCE)
    endif()

    set(FINAL_OPTION_VALUE ${${XBD_BOOL_OPT_NAME}})
    message(STATUS "Roblox Option: bool ${XBD_BOOL_OPT_NAME} = ${FINAL_OPTION_VALUE}")

    if (${XBD_BOOL_OPT_DEFINE_PREPROCESSOR} AND ${FINAL_OPTION_VALUE})
        add_compile_definitions(${XBD_BOOL_OPT_NAME})
    endif()
endfunction()
