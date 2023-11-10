
# Do not install by default
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY true)

# Unset configuration types and re-define them
set(RELEASE UNDEFINED)
set(DEBUG UNDEFINED)
set(CMAKE_CONFIGURATION_TYPES Debug Release CACHE STRING "Project configurations" FORCE)
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)
