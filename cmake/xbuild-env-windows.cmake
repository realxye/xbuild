include_guard(GLOBAL)

set(XBD_ENV_NAME "WINDOWS" CACHE INTERNAL "XBuild Environment Name")
set(XBD_ENV_WINDOWS ON CACHE BOOL "XBuild Environment Windows" FORCE)
message(STATUS "DEVENV: Windows")

# Find packages
#   -  WDK
find_package(WDK)