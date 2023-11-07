include_guard(GLOBAL)

#[[
XBuild internal options
]]

rbx_option_bool(
  NAME
    XBD_OPT_DISABLE_OPTIMIZATION
  DESCRIPTION
    "Disable optimization in release build"
  DEFAULT
    OFF
  DEFINE_PREPROCESSOR
)

rbx_option_bool(
  NAME
    XBD_OPT_DEBUG_VERBOSE
  DESCRIPTION
    "Output XBD debug information"
  DEFAULT
    OFF
)

rbx_option_bool(
  NAME
    XBD_OPT_BUILD_TIMING
  DESCRIPTION
    "Trace XBD build timing (LLVM Only)"
  DEFAULT
    OFF
)

rbx_option_bool(
  NAME
    XBD_OPT_TREAT_WARNINGS_AS_ERRORS
  DESCRIPTION
    "Treat all warnings as errors"
  DEFAULT
    ON
)

rbx_option_string(
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