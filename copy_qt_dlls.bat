@echo off
echo Copying Qt DLLs to output directory...

set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64

REM Check if QTDIR exists
if not exist "%QTDIR%" (
    echo Error: Qt directory not found at %QTDIR%
    echo Please check your Qt installation path.
    pause
    exit /b 1
)

REM Set output directory (adjust path as needed)
set OUTPUT_DIR=debug
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory...
    mkdir "%OUTPUT_DIR%"
)

echo Copying Qt DLLs...
copy "%QTDIR%\bin\Qt5Core.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5Gui.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5Widgets.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5WinExtras.dll" "%OUTPUT_DIR%\"

echo Copying Qt plugins...
if not exist "%OUTPUT_DIR%\plugins" mkdir "%OUTPUT_DIR%\plugins"
xcopy "%QTDIR%\plugins" "%OUTPUT_DIR%\plugins" /E /I /Y

echo Copying additional required DLLs...
copy "%QTDIR%\bin\Qt5Network.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\Qt5OpenGL.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\Qt5PrintSupport.dll" "%OUTPUT_DIR%\" 2>nul

echo Qt DLLs copied successfully!
echo You can now run TexasSolverGui.exe
pause
