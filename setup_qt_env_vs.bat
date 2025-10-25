@echo off
echo Setting up Qt environment for Visual Studio...

REM Set Qt environment variables
set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set PATH=%QTDIR%\bin;%PATH%
set QT_PLUGIN_PATH=%QTDIR%\plugins
set QT_QPA_PLATFORM_PLUGIN_PATH=%QTDIR%\plugins\platforms

echo QTDIR=%QTDIR%
echo PATH updated to include Qt bin directory
echo Qt environment variables set successfully!

REM Start Visual Studio with the environment
if "%1"=="start" (
    echo Starting Visual Studio...
    start "" "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" "TexasSolver.sln"
)
