include_guard(GLOBAL)

#[[
This is the master cmake file, the top level project cmake should include
this file at the very begin before call project()
]]

# Include utilities
include(rbx-util-options)
include(rbx-internal-options)
include(rbx-util-log)
include(rbx-util-core)
include(rbx-util-find)
include(rbx-util-cmake)

# Include build related scripts
include(rbx-env)
include(rbx-platform)
include(rbx-compiler)
