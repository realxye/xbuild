
#[[
Log helper functions
]]


# xbd_log_multiline(<prefix> <args...>)
# Helper function to print multi-line strings to STATUS
# prefixes each line with ${prefix}
# i.e. no prefix must pass empty string: xbd_log_muiltiline("" ${msg})
function(xbd_log_multiline prefix)
    string(REGEX REPLACE ";" "\\\\;" output "${ARGN}")
    string(REGEX REPLACE "\n" ";" output "${output}")
    foreach(line IN LISTS output)
        message(STATUS ${prefix}${line})
    endforeach()
endfunction()

# xbd_log_output_of_command(<args...>)
# Executes the passed in command and prints
# results to STATUS with a " > " prefix.
# Useful for capturing build machine config
# to the CMake log output.
function(xbd_log_output_of_command)
    string(REGEX REPLACE ";" " " CMD "${ARGN}")
    message(STATUS "command> ${CMD}")
    execute_process(
        COMMAND ${ARGN}
        OUTPUT_VARIABLE output
    )
    xbd_log_multiline("  > " ${output})
endfunction()
