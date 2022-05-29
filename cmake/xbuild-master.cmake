cmake_minimum_required(VERSION 3.15)
#################################################################
# This is master cmake file setting all the default settings.   #
#################################################################

# Set platform information
include($ENV{XBUILDROOT}/cmake/xbuild-common-platform.cmake)
# Include core functions
include($ENV{XBUILDROOT}/cmake/xbuild-common-core.cmake)
# Include common options
include($ENV{XBUILDROOT}/cmake/xbuild-common-options.cmake)
# Include common compiler information
include($ENV{XBUILDROOT}/cmake/xbuild-common-compiler.cmake)

# Copy Release linker flags to Optimized
set(CMAKE_EXE_LINKER_FLAGS_OPTIMIZED ${CMAKE_EXE_LINKER_FLAGS_RELEASE})
