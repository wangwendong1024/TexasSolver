@echo off
chcp 65001 >nul
echo ========================================
echo CUDA 12.6 自动安装脚本
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 需要管理员权限运行此脚本
    echo 请右键点击脚本，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo [信息] 检测到管理员权限，开始安装...
echo.

REM 设置变量
set "CUDA_VERSION=12.6"
set "CUDA_INSTALLER=cuda_12.6.0_560.94_windows.exe"
set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda_12.6.0_560.94_windows.exe"
set "CUDA_INSTALL_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6"
set "TEMP_DIR=%TEMP%\cuda_install"

echo [1] 创建临时目录...
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo [2] 检查现有CUDA安装...
if exist "%CUDA_INSTALL_PATH%" (
    echo [警告] 检测到现有CUDA安装：%CUDA_INSTALL_PATH%
    echo 是否要卸载旧版本？(Y/N)
    set /p choice="请选择: "
    if /i "%choice%"=="Y" (
        echo [信息] 卸载旧版本CUDA...
        wmic product where "name like 'NVIDIA CUDA%%'" call uninstall /nointeractive
        timeout /t 5 /nobreak >nul
    )
)

echo [3] 下载CUDA 12.6安装包...
echo 下载地址: %CUDA_URL%
echo 保存位置: %TEMP_DIR%\%CUDA_INSTALLER%
echo.

REM 使用PowerShell下载
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%CUDA_URL%' -OutFile '%TEMP_DIR%\%CUDA_INSTALLER%' -UseBasicParsing}"

if not exist "%TEMP_DIR%\%CUDA_INSTALLER%" (
    echo [错误] CUDA安装包下载失败
    echo 请手动下载: %CUDA_URL%
    pause
    exit /b 1
)

echo [成功] CUDA安装包下载完成
echo.

echo [4] 安装CUDA 12.6...
echo 正在运行安装程序，请稍候...
echo.

REM 静默安装CUDA
"%TEMP_DIR%\%CUDA_INSTALLER%" /s

REM 等待安装完成
echo [信息] 等待CUDA安装完成...
timeout /t 30 /nobreak >nul

echo [5] 验证CUDA安装...
if exist "%CUDA_INSTALL_PATH%\bin\nvcc.exe" (
    echo [成功] CUDA安装完成
) else (
    echo [错误] CUDA安装失败
    pause
    exit /b 1
)

echo [6] 配置环境变量...
REM 设置CUDA_PATH
setx CUDA_PATH "%CUDA_INSTALL_PATH%" /M
setx CUDA_PATH_V12_6 "%CUDA_INSTALL_PATH%" /M

REM 添加到PATH
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH') do set "CURRENT_PATH=%%b"
echo %CURRENT_PATH% | findstr /i "%CUDA_INSTALL_PATH%\bin" >nul
if %errorlevel% neq 0 (
    setx PATH "%CURRENT_PATH%;%CUDA_INSTALL_PATH%\bin;%CUDA_INSTALL_PATH%\libnvvp" /M
    echo [成功] 环境变量已更新
) else (
    echo [信息] 环境变量已存在
)

echo [7] 下载并安装cuDNN...
echo [信息] 正在下载cuDNN...
set "CUDNN_URL=https://developer.download.nvidia.com/compute/redist/cudnn/v8.9.7/cudnn-windows-x86_64-8.9.7.29_cuda12-archive.zip"
set "CUDNN_ZIP=%TEMP_DIR%\cudnn.zip"

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%CUDNN_URL%' -OutFile '%CUDNN_ZIP%' -UseBasicParsing}"

if exist "%CUDNN_ZIP%" (
    echo [信息] 解压cuDNN...
    powershell -Command "Expand-Archive -Path '%CUDNN_ZIP%' -DestinationPath '%TEMP_DIR%\cudnn' -Force"
    
    echo [信息] 复制cuDNN文件...
    xcopy "%TEMP_DIR%\cudnn\cudnn-windows-x86_64-8.9.7.29_cuda12-archive\bin\*" "%CUDA_INSTALL_PATH%\bin\" /Y /Q
    xcopy "%TEMP_DIR%\cudnn\cudnn-windows-x86_64-8.9.7.29_cuda12-archive\include\*" "%CUDA_INSTALL_PATH%\include\" /Y /Q
    xcopy "%TEMP_DIR%\cudnn\cudnn-windows-x86_64-8.9.7.29_cuda12-archive\lib\*" "%CUDA_INSTALL_PATH%\lib\" /Y /Q
    echo [成功] cuDNN安装完成
) else (
    echo [警告] cuDNN下载失败，请手动安装
)

echo [8] 清理临时文件...
rmdir /s /q "%TEMP_DIR%"

echo [9] 验证安装...
echo.
echo ========================================
echo 安装验证
echo ========================================

echo 检查CUDA版本:
"%CUDA_INSTALL_PATH%\bin\nvcc.exe" --version

echo.
echo 检查GPU信息:
nvidia-smi

echo.
echo ========================================
echo 安装完成！
echo ========================================
echo.
echo 请重启命令行或重新登录以使用新的环境变量
echo 然后运行 test_cuda_parallel_computing.bat 验证安装
echo.

pause
