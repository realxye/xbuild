include_guard(GLOBAL)

#[[
The common options for all compilers
]]

add_compile_options(
    # -DXBD_CONFIG_DEBUG | -DXBD_CONFIG_RELEASE
    -DXBD_CONFIG_$<UPPER_CASE:$<CONFIG>>
)

if (WIN32)
    # Common option for Widnows
    message(STATUS "Add common options for Widnows")
    # - Reproducible builds
    add_compile_options(/Brepro)
    add_link_options(/Brepro)
    # - Default exception handling model
    add_compile_options(/EHsc)
    # - Floating Point Model
    add_compile_options(/fp:precise)
    # - OmitFramePointers false
    add_compile_options(/Oy-)
    # - Enable Run-Time Type Information
    add_compile_options(/GR)
    # - Treat warnings as errors
    add_compile_options(/WX)
    # - Enable warnings up to level 3 on msvc and -Wall on clang 
    add_compile_options(/W3)
    # - All enumerators in a switch must be handled by an explicit or default case
    add_compile_options(/we4062)
    # - Format string argument type mismatch
    add_compile_options(/we4477)
    # - Signed/Unsigned mismatch
    add_compile_options(/wd4018)
    # - local variable is initialized but not referenced (level 4)
    add_compile_options(/we4189)
    # - C4731: frame pointer register 'ebx' modified by inline assembly code
    # This warning is triggered by inline assembly in our VMProtect markers when LTCG is used
    # for codegen. Disable it to get VMProtect working with LTCG.
    add_compile_options(/wd4731)
    # - These are some other warnings that are worth considering but that we are not enabling:
    # C4101: Unreferenced local variable. This is a level 3 warning so it's already enabled (unless we change the default warning level).
    add_compile_options(/we4101)
    # - C4100: Unreference formal parameter. There's not an equivalent warning in clang and we want all targets to error the same way.
    add_compile_options(/we4100)
    # - C4505: Unused local function has been removed. This is very similar to -Wunused-function and we may want to enable it in the future
    #        to improve consistency with clang. However, to enable it we would have to fix many errors and this needs to be studied in more
    #        detail.
    add_compile_options(/we4505)
else()
    # Common options for Non-Windows
    message(STATUS "Add common options for Non-Widnows")
    # - All enumerators in a switch must be handled by an explicit or default case
    add_compile_options(-Wno-switch)
endif()
