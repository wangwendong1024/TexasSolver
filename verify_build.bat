@echo off
REM 验证VS Studio构建是否包含所有必要文件

echo ========================================
echo Verifying VS Studio Build
echo ========================================

set RELEASE_DIR=release
set DOWNLOAD_DIR=C:\Users\Administrator\Downloads\TexasSolver-v0.2.0-Windows

echo Checking essential files...

REM 检查主程序
if exist "%RELEASE_DIR%\TexasSolverGui.exe" (
    echo ✓ TexasSolverGui.exe found
) else (
    echo ✗ TexasSolverGui.exe NOT found
)

REM 检查翻译文件
if exist "%RELEASE_DIR%\lang_cn.qm" (
    echo ✓ lang_cn.qm found
) else (
    echo ✗ lang_cn.qm NOT found
)
if exist "%RELEASE_DIR%\lang_en.qm" (
    echo ✓ lang_en.qm found
) else (
    echo ✗ lang_en.qm NOT found
)

REM 检查ranges文件夹
if exist "%RELEASE_DIR%\ranges" (
    echo ✓ ranges folder found
) else (
    echo ✗ ranges folder NOT found
)

REM 检查资源文件
if exist "%RELEASE_DIR%\resources\compairer" (
    echo ✓ resources/compairer folder found
    dir "%RELEASE_DIR%\resources\compairer" /B
) else (
    echo ✗ resources/compairer folder NOT found
)

REM 检查参数文件
if exist "%RELEASE_DIR%\parameters" (
    echo ✓ parameters folder found
) else (
    echo ✗ parameters folder NOT found
)

REM 检查DLL文件
echo.
echo Checking DLL files...
if exist "%RELEASE_DIR%\D3Dcompiler_47.dll" echo ✓ D3Dcompiler_47.dll
if exist "%RELEASE_DIR%\libEGL.dll" echo ✓ libEGL.dll
if exist "%RELEASE_DIR%\libGLESV2.dll" echo ✓ libGLESV2.dll
if exist "%RELEASE_DIR%\opengl32sw.dll" echo ✓ opengl32sw.dll
if exist "%RELEASE_DIR%\Qt5Svg.dll" echo ✓ Qt5Svg.dll

REM 检查console_solver.exe
if exist "%RELEASE_DIR%\console_solver.exe" (
    echo ✓ console_solver.exe found
) else (
    echo ✗ console_solver.exe NOT found
    echo   Run copy_missing_files.bat to copy from downloaded version
)

echo.
echo ========================================
echo Verification completed!
echo ========================================
echo.
echo If all items show ✓, your VS Studio build should work like the downloaded version.
echo.
pause
