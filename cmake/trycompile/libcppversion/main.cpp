#include <cstddef>
#include <iostream>

#define XSTR(x) STR(x)
#define STR(x)  #x

#pragma message "libc++ version: " XSTR(_LIBCPP_VERSION)

__attribute__((used)) void dummy()
{
}
