include_guard(GLOBAL)

#[[
This is the master cmake file, the top level project cmake should include
this file at the very begin before call project()
]]

# Include utilities
include(xbuild-util-options)
include(xbuild-internal-options)
include(xbuild-util-log)
include(xbuild-util-core)
include(xbuild-util-find)

