cmake_minimum_required(VERSION 3.15)

project(XBuildSamples)

# Common
add_subdirectory(simple_console)
add_subdirectory(simple_slib)

# MacOS
#if(APPLE)
#    add_subdirectory(simple_dynlib)
#endif()

# Windows
if(WIN32)
    add_subdirectory(simple_win32_app)
    add_subdirectory(simple_win32_dll)
    add_subdirectory(simple_win32_drv)
else()
    add_subdirectory(simple_so)
endif()
