# TexasSolver 安装规则
# 用于生成整齐的发布包

# 设置安装目录
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/TexasSolver-v0.2.0-Windows")

# 安装可执行文件
install(TARGETS TexasSolverGui
    RUNTIME DESTINATION .
    BUNDLE DESTINATION .
)

# 安装Qt库
install(FILES
    ${QT_DIR}/bin/Qt5Core.dll
    ${QT_DIR}/bin/Qt5Gui.dll
    ${QT_DIR}/bin/Qt5Widgets.dll
    ${QT_DIR}/bin/Qt5Svg.dll
    ${QT_DIR}/bin/D3Dcompiler_47.dll
    ${QT_DIR}/bin/libEGL.dll
    ${QT_DIR}/bin/libGLESV2.dll
    ${QT_DIR}/bin/opengl32sw.dll
    DESTINATION .
)

# 安装Qt插件
install(DIRECTORY ${QT_DIR}/plugins/iconengines
    DESTINATION iconengines
    FILES_MATCHING PATTERN "*.dll"
)

install(DIRECTORY ${QT_DIR}/plugins/imageformats
    DESTINATION imageformats
    FILES_MATCHING PATTERN "*.dll"
)

install(DIRECTORY ${QT_DIR}/plugins/platforms
    DESTINATION platforms
    FILES_MATCHING PATTERN "*.dll"
)

# 安装资源文件
install(DIRECTORY ${CMAKE_SOURCE_DIR}/resources
    DESTINATION resources
)

# 安装参数文件
install(DIRECTORY ${CMAKE_SOURCE_DIR}/parameters
    DESTINATION parameters
)

# 安装翻译文件
install(DIRECTORY ${QT_DIR}/translations
    DESTINATION translations
    FILES_MATCHING PATTERN "*.qm"
)

# 安装范围文件（如果存在）
if(EXISTS "${CMAKE_SOURCE_DIR}/ranges")
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/ranges
        DESTINATION ranges
    )
endif()
