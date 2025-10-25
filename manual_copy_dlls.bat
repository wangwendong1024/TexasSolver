@echo off
echo Manually copying Qt DLLs to debug directory...

set QT_PATH=C:\qt\pc_5.15\5.15.0\msvc2019_64
set OUTPUT_DIR=debug

echo Copying Qt DLLs to: %OUTPUT_DIR%

REM Copy main Qt DLLs
copy "%QT_PATH%\bin\Qt5Core.dll" "%OUTPUT_DIR%\"
copy "%QT_PATH%\bin\Qt5Gui.dll" "%OUTPUT_DIR%\"
copy "%QT_PATH%\bin\Qt5Widgets.dll" "%OUTPUT_DIR%\"
copy "%QT_PATH%\bin\Qt5WinExtras.dll" "%OUTPUT_DIR%\"

REM Copy additional DLLs that might be needed
copy "%QT_PATH%\bin\Qt5Network.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QT_PATH%\bin\Qt5OpenGL.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QT_PATH%\bin\Qt5PrintSupport.dll" "%OUTPUT_DIR%\" 2>nul

REM Copy plugins
if not exist "%OUTPUT_DIR%\plugins" mkdir "%OUTPUT_DIR%\plugins"
xcopy "%QT_PATH%\plugins" "%OUTPUT_DIR%\plugins" /E /I /Y

echo Copy completed!
echo You can now run TexasSolverGui.exe
pause
