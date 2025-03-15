
xbd_target_sources(${TARGETNAME}
    SUBDIR include
    SOURCES
    ${TARGETNAME}/${TARGETNAME}.h
)

xbd_target_sources(${TARGETNAME}
    SUBDIR src
    SOURCES
    ${TARGETNAME}.cpp
)
