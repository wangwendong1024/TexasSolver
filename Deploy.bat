@echo off
REM 一键部署脚本 - 在Visual Studio中调用
echo ========================================
echo TexasSolver Deployment Package Creator
echo ========================================

REM 设置路径
set PROJECT_DIR=%~dp0
set DEPLOY_DIR=%PROJECT_DIR%TexasSolver-v0.2.0-Windows

echo Project directory: %PROJECT_DIR%
echo Deploy directory: %DEPLOY_DIR%

REM 清理旧部署目录
if exist "%DEPLOY_DIR%" (
    echo Cleaning old deployment directory...
    rmdir /s /q "%DEPLOY_DIR%"
)

REM 创建部署目录
mkdir "%DEPLOY_DIR%"

echo.
echo Step 1: Copying main executable...
if exist "release\TexasSolverGui.exe" (
    copy "release\TexasSolverGui.exe" "%DEPLOY_DIR%\"
    echo ✓ Main executable copied
) else (
    echo ✗ Main executable not found in release directory
)

echo.
echo Step 2: Copying Qt libraries...
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Core.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Gui.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Widgets.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\Qt5Svg.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\D3Dcompiler_47.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\libEGL.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\libGLESV2.dll" "%DEPLOY_DIR%\" 2>nul
copy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\bin\opengl32sw.dll" "%DEPLOY_DIR%\" 2>nul
echo ✓ Qt libraries copied

echo.
echo Step 3: Copying Qt plugins...
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\iconengines" "%DEPLOY_DIR%\iconengines\" /E /I /Y /Q
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\imageformats" "%DEPLOY_DIR%\imageformats\" /E /I /Y /Q
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\plugins\platforms" "%DEPLOY_DIR%\platforms\" /E /I /Y /Q
echo ✓ Qt plugins copied

echo.
echo Step 4: Copying resources...
xcopy "%PROJECT_DIR%resources" "%DEPLOY_DIR%\resources\" /E /I /Y /Q
echo ✓ Resources copied

echo.
echo Step 5: Copying parameters...
xcopy "%PROJECT_DIR%parameters" "%DEPLOY_DIR%\parameters\" /E /I /Y /Q
echo ✓ Parameters copied

echo.
echo Step 6: Copying translations...
xcopy "E:\qt\pc\qt_5.15\5.15.0\msvc2019_64\translations" "%DEPLOY_DIR%\translations\" /E /I /Y /Q
echo ✓ Translations copied

echo.
echo ========================================
echo Deployment package created successfully!
echo Location: %DEPLOY_DIR%
echo ========================================
echo.
echo Package structure:
dir "%DEPLOY_DIR%" /B
echo.
echo Total files: 
dir "%DEPLOY_DIR%" /S /B | find /C /V ""
echo.
echo Deployment completed!
