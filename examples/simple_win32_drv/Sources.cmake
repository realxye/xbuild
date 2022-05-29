# Sources
target_sources(SimpleDrv PRIVATE
    src/drv.rc
    src/entry.cpp
)

# Headers
target_sources(SimpleDrv PRIVATE
    SUBDIR include/simple_drv_name/
    simpledrv.h
)
