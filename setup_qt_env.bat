@echo off
echo Setting up Qt environment for Visual Studio 2022...

REM Set Qt installation path
set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64

REM Add Qt bin directory to PATH
set PATH=%QTDIR%\bin;%PATH%

REM Set Qt environment variables
set QT_PLUGIN_PATH=%QTDIR%\plugins
set QT_QPA_PLATFORM_PLUGIN_PATH=%QTDIR%\plugins\platforms

echo Qt environment configured:
echo QTDIR=%QTDIR%
echo PATH updated with Qt bin directory
echo QT_PLUGIN_PATH=%QT_PLUGIN_PATH%
echo QT_QPA_PLATFORM_PLUGIN_PATH=%QT_QPA_PLATFORM_PLUGIN_PATH%

echo.
echo You can now open TexasSolver.sln in Visual Studio 2022
echo Make sure to select the correct Qt version in Qt VS Tools
pause
