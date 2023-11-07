
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
