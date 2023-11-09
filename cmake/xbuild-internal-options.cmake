include_guard(GLOBAL)

#[[
XBuild internal options
]]

xbd_option_bool(
  NAME
    XBD_OPT_DISABLE_OPTIMIZATION
  DESCRIPTION
    "Disable optimization in release build"
  DEFAULT
    OFF
  DEFINE_PREPROCESSOR
)

xbd_option_bool(
  NAME
    XBD_OPT_DEBUG_VERBOSE
  DESCRIPTION
    "Output XBD debug information"
  DEFAULT
    OFF
)

xbd_option_bool(
  NAME
    XBD_OPT_BUILD_TIMING
  DESCRIPTION
    "Trace XBD build timing (LLVM Only)"
  DEFAULT
    OFF
)

xbd_option_string(
  NAME
    XBD_OPT_BUILD_PLATFORM
  DESCRIPTION
    "The build's target platform"
  CHOICES
    windows macos ios linux android unknown
  MAKE_AVAILABLE_IF
    "${CMAKE_SYSTEM_NAME} MATCHES Windows" windows
    "${CMAKE_SYSTEM_NAME} MATCHES Darwin" macos
    "${CMAKE_SYSTEM_NAME} MATCHES Linux" linux
  DEFAULT
    unknown
  TOLOWER
  DEFINE_PREPROCESSOR
)

xbd_option_bool(
  NAME
    XBD_OPT_TREAT_WARNINGS_AS_ERRORS
  DESCRIPTION
    "Treat all warnings as errors"
  DEFAULT
    ON
)

xbd_option_string(
  NAME
    XBD_OPT_USE_SANITIZER
  DESCRIPTION
    "Which sanitizer to use"
  CHOICES
    thread address memory undefined none
  DEFAULT
    none
  TOLOWER
)