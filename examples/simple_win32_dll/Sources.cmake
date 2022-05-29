# Sources
target_sources(SimpleDll PRIVATE
    src/dllmain.rc
    src/dllmain.cpp
)

# Headers
target_sources(SimpleDll PRIVATE
    SUBDIR include/simple_dll_name/
    simple.h
)
