@echo off
REM TexasSolver 应用程序部署脚本
echo Creating deployment directory...

REM 创建部署目录
set DEPLOY_DIR=TexasSolver-v0.2.0-Windows
if exist "%DEPLOY_DIR%" rmdir /s /q "%DEPLOY_DIR%"
mkdir "%DEPLOY_DIR%"

REM 复制主程序
copy "debug\TexasSolverGui.exe" "%DEPLOY_DIR%\"
copy "debug\console_solver.exe" "%DEPLOY_DIR%\"

REM 复制Qt DLL文件
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Core.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Gui.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Widgets.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\Qt5Svg.dll" "%DEPLOY_DIR%\"

REM 复制系统DLL
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\D3Dcompiler_47.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\libEGL.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\libGLESV2.dll" "%DEPLOY_DIR%\"
copy "C:\qt\pc_5.15\5.15.0\msvc2019_64\bin\opengl32sw.dll" "%DEPLOY_DIR%\"

REM 复制Qt插件
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\iconengines" "%DEPLOY_DIR%\iconengines\" /E /I /Y
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\imageformats" "%DEPLOY_DIR%\imageformats\" /E /I /Y
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\plugins\platforms" "%DEPLOY_DIR%\platforms\" /E /I /Y

REM 复制资源文件
xcopy "resources" "%DEPLOY_DIR%\resources\" /E /I /Y

REM 复制参数文件
xcopy "parameters" "%DEPLOY_DIR%\parameters\" /E /I /Y

REM 复制翻译文件
xcopy "C:\qt\pc_5.15\5.15.0\msvc2019_64\translations" "%DEPLOY_DIR%\translations\" /E /I /Y

REM 复制范围文件（如果存在）
if exist "ranges" xcopy "ranges" "%DEPLOY_DIR%\ranges\" /E /I /Y

echo Deployment completed successfully!
echo Deployment directory: %DEPLOY_DIR%
pause
