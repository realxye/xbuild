
# Do not install by default
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY true)

if(EXISTS "${ROOT}/configuration/${customer}/configuration.${project_name}.xml")
   ...
else()
   ...
endif()

# Unset configuration types and re-define them
set(RELEASE UNDEFINED)
set(DEBUG UNDEFINED)
set(NOOPT UNDEFINED)
set(OPTIMIZED UNDEFINED)
set(CMAKE_CONFIGURATION_TYPES NoOpt Optimized Release CACHE STRING "Project configurations" FORCE)

set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS NoOpt)
