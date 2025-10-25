@echo off
REM TexasSolver 部署包创建脚本
echo Creating deployment package...

set DEPLOY_DIR=TexasSolver-v0.2.0-Windows
set PROJECT_DIR=%~dp0
set OUT_DIR=%PROJECT_DIR%release

REM 清理旧的部署目录
if exist "%DEPLOY_DIR%" rmdir /s /q "%DEPLOY_DIR%"
mkdir "%DEPLOY_DIR%"

echo Copying main executable...
copy "%OUT_DIR%\TexasSolverGui.exe" "%DEPLOY_DIR%\"

echo Copying Qt libraries...
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Core.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Gui.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Widgets.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Svg.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\D3Dcompiler_47.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\libEGL.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\libGLESV2.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\opengl32sw.dll" "%DEPLOY_DIR%\"

echo Copying Qt plugins...
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\iconengines" "%DEPLOY_DIR%\iconengines\" /E /I /Y
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\imageformats" "%DEPLOY_DIR%\imageformats\" /E /I /Y
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\platforms" "%DEPLOY_DIR%\platforms\" /E /I /Y

echo Copying resources...
xcopy "%PROJECT_DIR%resources" "%DEPLOY_DIR%\resources\" /E /I /Y

echo Copying parameters...
xcopy "%PROJECT_DIR%parameters" "%DEPLOY_DIR%\parameters\" /E /I /Y

echo Copying translations...
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\translations" "%DEPLOY_DIR%\translations\" /E /I /Y

echo.
echo ========================================
echo Deployment package created successfully!
echo Location: %DEPLOY_DIR%
echo ========================================
echo.
echo Package contents:
dir "%DEPLOY_DIR%" /B
echo.
pause
