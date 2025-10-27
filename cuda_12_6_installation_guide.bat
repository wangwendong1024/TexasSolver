@echo off
chcp 65001 >nul
echo ========================================
echo CUDA 12.6 完整安装方案
echo ========================================
echo.

echo 根据检测结果，您的系统缺少以下组件：
echo 1. CUDA 12.6 Toolkit (最新版本)
echo 2. Visual Studio 2019/2022 (用于CUDA开发)
echo 3. cuDNN库 (深度学习加速)
echo 4. MSBuild工具
echo.

echo ========================================
echo 第一步：下载CUDA 12.6 Toolkit
echo ========================================
echo.
echo 1. 访问NVIDIA官方下载页面：
echo    https://developer.nvidia.com/cuda-12-6-0-download-archive
echo.
echo 2. 选择以下配置：
echo    - Operating System: Windows
echo    - Architecture: x86_64
echo    - Version: 10/11
echo    - Installer Type: exe (network) 或 exe (local)
echo.
echo 3. 下载文件：cuda_12.6.0_560.94_windows.exe
echo.

echo ========================================
echo 第二步：安装Visual Studio
echo ========================================
echo.
echo 1. 下载Visual Studio 2022 Community (免费)：
echo    https://visualstudio.microsoft.com/zh-hans/vs/community/
echo.
echo 2. 安装时选择以下工作负载：
echo    ✓ 使用C++的桌面开发
echo    ✓ 使用C++的游戏开发
echo    ✓ .NET桌面开发
echo.
echo 3. 在"单个组件"中确保选择：
echo    ✓ MSVC v143 - VS 2022 C++ x64/x86生成工具
echo    ✓ Windows 10/11 SDK (最新版本)
echo    ✓ CMake工具
echo.

echo ========================================
echo 第三步：安装CUDA 12.6
echo ========================================
echo.
echo 1. 以管理员身份运行下载的cuda_12.6.0_560.94_windows.exe
echo.
echo 2. 选择"自定义安装"
echo.
echo 3. 确保选择以下组件：
echo    ✓ CUDA Toolkit 12.6
echo    ✓ CUDA Samples 12.6
echo    ✓ CUDA Documentation 12.6
echo    ✓ CUDA Demo Suite 12.6
echo.
echo 4. 安装路径保持默认：
echo    C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6
echo.

echo ========================================
echo 第四步：安装cuDNN
echo ========================================
echo.
echo 1. 访问cuDNN下载页面：
echo    https://developer.nvidia.com/cudnn
echo.
echo 2. 需要注册NVIDIA开发者账号
echo.
echo 3. 下载cuDNN v8.9.7 for CUDA 12.x：
echo    cudnn-windows-x86_64-8.9.7.29_cuda12-archive.zip
echo.
echo 4. 解压后复制文件到CUDA安装目录：
echo    - 复制bin\* 到 C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6\bin\
echo    - 复制include\* 到 C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6\include\
echo    - 复制lib\* 到 C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6\lib\
echo.

echo ========================================
echo 第五步：配置环境变量
echo ========================================
echo.
echo 1. 打开系统环境变量设置
echo 2. 在"系统变量"中添加：
echo    CUDA_PATH = C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6
echo    CUDA_PATH_V12_6 = C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.6
echo.
echo 3. 在Path中添加：
echo    %CUDA_PATH%\bin
echo    %CUDA_PATH%\libnvvp
echo.

echo ========================================
echo 第六步：验证安装
echo ========================================
echo.
echo 安装完成后，运行以下命令验证：
echo.
echo 1. 检查CUDA版本：
echo    nvcc --version
echo.
echo 2. 检查GPU信息：
echo    nvidia-smi
echo.
echo 3. 运行我们的检测脚本：
echo    test_cuda_parallel_computing.bat
echo.

echo ========================================
echo 常见问题解决
echo ========================================
echo.
echo 问题1：nvcc命令未找到
echo 解决：重启命令行，确保环境变量生效
echo.
echo 问题2：Visual Studio未检测到
echo 解决：确保安装了"使用C++的桌面开发"工作负载
echo.
echo 问题3：编译错误
echo 解决：检查Visual Studio版本兼容性，建议使用VS 2022
echo.
echo 问题4：运行时错误
echo 解决：确保CUDA运行时库在PATH中
echo.

echo ========================================
echo 快速安装脚本
echo ========================================
echo.
echo 我也可以为您创建一个自动安装脚本，包含：
echo 1. 自动下载CUDA 12.6
echo 2. 静默安装配置
echo 3. 自动配置环境变量
echo 4. 验证安装结果
echo.
echo 是否需要我创建这个自动安装脚本？
echo.

pause
