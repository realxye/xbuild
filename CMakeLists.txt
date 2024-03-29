cmake_minimum_required(VERSION 3.26.5)
include(CMakeDependentOption)
include(CMakePrintHelpers)
include(FeatureSummary)

# 🚨 NEVER EVER EVER EVER. CALL `project()` IN THIS CMakeLists.txt file!! 🚨
set(CMAKE_DISABLE_IN_SOURCE_BUILD YES CACHE BOOL "Prevents accidental cmake -B. -S.")

#set(XBUILD_PRELUDE_CMAKE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake" CACHE PATH "XBuild CMake Prelude directory")
#set(XBUILD_PRELUDE_PACKAGES_DIR "${XBUILD_PRELUDE_CMAKE_DIR}/packages" CACHE PATH "XBuild CMake Prelude find_package directory")
#list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
#list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/packages")
#list(APPEND CMAKE_MESSAGE_CONTEXT prelude)

set(XBUILD_CMAKE_IS_CHILD ON)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/xbuild-prelude.cmake)


if (DEFINED ENV{XBUILD_FETCHCONTENT_BASE_DIR})
    # We use FORCE because the FetchContent for prelude sets FETCHCONTENT_BASE_DIR, which we want to override for all further fetched content
    set(FETCHCONTENT_BASE_DIR "$ENV{XBUILD_FETCHCONTENT_BASE_DIR}" CACHE PATH "Override FetchContent cache dir outside of the build tree to this path" FORCE)
endif()

# We do not want the average person calling these functions.
# They are reserved for the prelude. Hence the 🈯 (reserved) emoji.
#cmake_language(CALL 🈯::xbuild::prelude::cmake-file-api)
#cmake_language(CALL 🈯::xbuild::prelude::properties)
#cmake_language(CALL 🈯::xbuild::prelude::policies)
#cmake_language(CALL 🈯::xbuild::prelude::globals)