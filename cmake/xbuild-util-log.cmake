
#[[
Log helper functions
]]


# rbx_log_multiline(<prefix> <args...>)
# Helper function to print multi-line strings to STATUS
# prefixes each line with ${prefix}
# i.e. no prefix must pass empty string: rbx_log_muiltiline("" ${msg})
function(rbx_log_multiline prefix)
    string(REGEX REPLACE ";" "\\\\;" output "${ARGN}")
    string(REGEX REPLACE "\n" ";" output "${output}")
    foreach(line IN LISTS output)
        message(STATUS ${prefix}${line})
    endforeach()
endfunction()

# rbx_log_output_of_command(<args...>)
# Executes the passed in command and prints
# results to STATUS with a " > " prefix.
# Useful for capturing build machine config
# to the CMake log output.
function(rbx_log_output_of_command)
    string(REGEX REPLACE ";" " " CMD "${ARGN}")
    message(STATUS "command> ${CMD}")
    execute_process(
        COMMAND ${ARGN}
        OUTPUT_VARIABLE output
    )
    rbx_log_multiline("  > " ${output})
endfunction()
