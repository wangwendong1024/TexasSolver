@echo off
echo Post-build: Copying Qt DLLs...

set QT_PATH=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set OUTPUT_DIR=%~1

if "%OUTPUT_DIR%"=="" (
    echo Error: Output directory not specified
    exit /b 1
)

echo Copying Qt DLLs to: %OUTPUT_DIR%

REM Copy main Qt DLLs
if exist "%QT_PATH%\bin\Qt5Core.dll" (
    copy "%QT_PATH%\bin\Qt5Core.dll" "%OUTPUT_DIR%\" >nul
    echo Copied Qt5Core.dll
) else (
    echo Warning: Qt5Core.dll not found
)

if exist "%QT_PATH%\bin\Qt5Gui.dll" (
    copy "%QT_PATH%\bin\Qt5Gui.dll" "%OUTPUT_DIR%\" >nul
    echo Copied Qt5Gui.dll
) else (
    echo Warning: Qt5Gui.dll not found
)

if exist "%QT_PATH%\bin\Qt5Widgets.dll" (
    copy "%QT_PATH%\bin\Qt5Widgets.dll" "%OUTPUT_DIR%\" >nul
    echo Copied Qt5Widgets.dll
) else (
    echo Warning: Qt5Widgets.dll not found
)

if exist "%QT_PATH%\bin\Qt5WinExtras.dll" (
    copy "%QT_PATH%\bin\Qt5WinExtras.dll" "%OUTPUT_DIR%\" >nul
    echo Copied Qt5WinExtras.dll
) else (
    echo Warning: Qt5WinExtras.dll not found
)

REM Copy plugins
if exist "%QT_PATH%\plugins" (
    if not exist "%OUTPUT_DIR%\plugins" mkdir "%OUTPUT_DIR%\plugins"
    xcopy "%QT_PATH%\plugins" "%OUTPUT_DIR%\plugins" /E /I /Y >nul
    echo Copied Qt plugins
) else (
    echo Warning: Qt plugins directory not found
)

echo Post-build copy completed!
