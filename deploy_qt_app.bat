@echo off
echo Deploying Qt application with all dependencies...

set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set APP_NAME=TexasSolverGui
set OUTPUT_DIR=deploy

REM Create deployment directory
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

echo Copying executable...
copy "debug\%APP_NAME%.exe" "%OUTPUT_DIR%\"

echo Copying Qt DLLs...
copy "%QTDIR%\bin\Qt5Core.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5Gui.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5Widgets.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5WinExtras.dll" "%OUTPUT_DIR%\"
copy "%QTDIR%\bin\Qt5Network.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\Qt5OpenGL.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\Qt5PrintSupport.dll" "%OUTPUT_DIR%\" 2>nul

echo Copying Qt plugins...
xcopy "%QTDIR%\plugins" "%OUTPUT_DIR%\plugins" /E /I /Y

echo Copying Visual C++ Redistributable DLLs...
REM These are usually in System32, but we'll copy from Qt bin if available
copy "%QTDIR%\bin\msvcp140.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\vcruntime140.dll" "%OUTPUT_DIR%\" 2>nul
copy "%QTDIR%\bin\vcruntime140_1.dll" "%OUTPUT_DIR%\" 2>nul

echo Creating run script...
echo @echo off > "%OUTPUT_DIR%\run.bat"
echo echo Starting TexasSolverGui... >> "%OUTPUT_DIR%\run.bat"
echo %APP_NAME%.exe >> "%OUTPUT_DIR%\run.bat"
echo pause >> "%OUTPUT_DIR%\run.bat"

echo Deployment complete!
echo Executable location: %OUTPUT_DIR%\%APP_NAME%.exe
echo You can now distribute the entire %OUTPUT_DIR% folder.
pause
