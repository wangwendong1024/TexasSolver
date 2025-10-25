@echo off
REM 复制缺失的文件到输出目录
REM 这个脚本需要手动运行，或者从下载的版本中复制缺失的文件

set RELEASE_DIR=release
set DOWNLOAD_DIR=C:\Users\Administrator\Downloads\TexasSolver-v0.2.0-Windows

echo ========================================
echo Copying missing files from downloaded version
echo ========================================

REM 检查下载目录是否存在
if not exist "%DOWNLOAD_DIR%" (
    echo Error: Download directory not found: %DOWNLOAD_DIR%
    echo Please update the DOWNLOAD_DIR variable in this script
    pause
    exit /b 1
)

REM 复制缺失的DLL文件
echo Copying DLL files...
if exist "%DOWNLOAD_DIR%\D3Dcompiler_47.dll" copy "%DOWNLOAD_DIR%\D3Dcompiler_47.dll" "%RELEASE_DIR%\"
if exist "%DOWNLOAD_DIR%\libEGL.dll" copy "%DOWNLOAD_DIR%\libEGL.dll" "%RELEASE_DIR%\"
if exist "%DOWNLOAD_DIR%\libGLESV2.dll" copy "%DOWNLOAD_DIR%\libGLESV2.dll" "%RELEASE_DIR%\"
if exist "%DOWNLOAD_DIR%\opengl32sw.dll" copy "%DOWNLOAD_DIR%\opengl32sw.dll" "%RELEASE_DIR%\"
if exist "%DOWNLOAD_DIR%\Qt5Svg.dll" copy "%DOWNLOAD_DIR%\Qt5Svg.dll" "%RELEASE_DIR%\"

REM 复制console_solver.exe
if exist "%DOWNLOAD_DIR%\console_solver.exe" copy "%DOWNLOAD_DIR%\console_solver.exe" "%RELEASE_DIR%\"

REM 复制ranges文件夹
if exist "%DOWNLOAD_DIR%\ranges" (
    echo Copying ranges folder...
    if not exist "%RELEASE_DIR%\ranges" mkdir "%RELEASE_DIR%\ranges"
    xcopy "%DOWNLOAD_DIR%\ranges" "%RELEASE_DIR%\ranges\" /E /I /Y
)

REM 复制翻译文件（如果VS版本缺少）
if exist "%DOWNLOAD_DIR%\lang_cn.qm" copy "%DOWNLOAD_DIR%\lang_cn.qm" "%RELEASE_DIR%\"
if exist "%DOWNLOAD_DIR%\lang_en.qm" copy "%DOWNLOAD_DIR%\lang_en.qm" "%RELEASE_DIR%\"

echo.
echo ========================================
echo Copy completed!
echo ========================================
echo.
echo Now your VS Studio build should have all the missing files.
echo.
pause