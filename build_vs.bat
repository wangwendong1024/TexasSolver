@echo off
echo Setting up Visual Studio 2022 environment...

REM Set Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Set Qt environment
set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set PATH=%QTDIR%\bin;%PATH%

echo Building TexasSolver project...
echo Qt path: %QTDIR%

REM Build the project using MSBuild
msbuild TexasSolver.sln /p:Configuration=Release /p:Platform=x64

echo Build completed!
pause
