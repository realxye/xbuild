include_guard(DIRECTORY)

#[[
This is the master cmake file, the top level project cmake should include
this file at the very begin before call project()
]]

function (xbd_project)
    project(${ARGN})
    # Enable message context
    set(CMAKE_MESSAGE_CONTEXT "${PROJECT_NAME}")
    set(CMAKE_MESSAGE_CONTEXT "${PROJECT_NAME}" PARENT_SCOPE)
    # Include build related scripts
    include(xbuild-platform)
    include(xbuild-compiler)
    include(xbuild-util-cmake)
endfunction()