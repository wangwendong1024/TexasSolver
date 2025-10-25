@echo off
REM Visual Studio 部署脚本
echo Creating deployment package from Visual Studio...

set DEPLOY_DIR=TexasSolver-v0.2.0-Windows
set PROJECT_DIR=%~dp0

REM 清理旧的部署目录
if exist "%DEPLOY_DIR%" rmdir /s /q "%DEPLOY_DIR%"
mkdir "%DEPLOY_DIR%"

echo Copying files to deployment package...

REM 复制主程序
copy "TexasSolverGui.exe" "%DEPLOY_DIR%\"

REM 复制Qt库
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Core.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Gui.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Widgets.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Svg.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\D3Dcompiler_47.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\libEGL.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\libGLESV2.dll" "%DEPLOY_DIR%\"
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\opengl32sw.dll" "%DEPLOY_DIR%\"

REM 复制Qt插件
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\iconengines" "%DEPLOY_DIR%\iconengines\" /E /I /Y
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\imageformats" "%DEPLOY_DIR%\imageformats\" /E /I /Y
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\platforms" "%DEPLOY_DIR%\platforms\" /E /I /Y

REM 复制资源文件
xcopy "%PROJECT_DIR%resources" "%DEPLOY_DIR%\resources\" /E /I /Y

REM 复制参数文件
xcopy "%PROJECT_DIR%parameters" "%DEPLOY_DIR%\parameters\" /E /I /Y

REM 复制翻译文件
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\translations" "%DEPLOY_DIR%\translations\" /E /I /Y

echo.
echo ========================================
echo Deployment package created: %DEPLOY_DIR%
echo ========================================
