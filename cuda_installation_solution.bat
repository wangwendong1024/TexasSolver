@echo off
chcp 65001 >nul
echo ========================================
echo CUDA 12.6 快速安装指南
echo ========================================
echo.

echo 根据您的检测结果，需要安装以下组件：
echo.
echo [问题分析]
echo ✓ NVIDIA GPU: RTX 2080 Ti (已检测到)
echo ✓ CUDA环境变量: 已设置
echo ✗ nvcc编译器: 未找到
echo ✗ CUDA运行时库: 未找到
echo ✗ Visual Studio: 未检测到
echo ✗ MSBuild: 不可用
echo.

echo ========================================
echo 解决方案
echo ========================================
echo.

echo [方案1: 自动安装 (推荐)]
echo 1. 右键点击 auto_install_cuda_12_6.bat
echo 2. 选择"以管理员身份运行"
echo 3. 等待自动安装完成
echo.

echo [方案2: 手动安装]
echo 1. 下载CUDA 12.6:
echo    https://developer.nvidia.com/cuda-12-6-0-download-archive
echo    选择: Windows x86_64, exe (network)
echo.
echo 2. 下载Visual Studio 2022 Community:
echo    https://visualstudio.microsoft.com/zh-hans/vs/community/
echo    安装时选择"使用C++的桌面开发"
echo.
echo 3. 运行CUDA安装程序:
echo    - 选择"自定义安装"
echo    - 确保选择所有CUDA组件
echo    - 安装到默认路径
echo.
echo 4. 重启计算机
echo.

echo ========================================
echo 验证安装
echo ========================================
echo.
echo 安装完成后，运行以下命令验证：
echo.
echo 1. 检查CUDA版本:
echo    nvcc --version
echo.
echo 2. 检查GPU:
echo    nvidia-smi
echo.
echo 3. 运行检测脚本:
echo    test_cuda_parallel_computing.bat
echo.

echo ========================================
echo 常见问题
echo ========================================
echo.
echo Q: nvcc命令未找到
echo A: 重启命令行，确保环境变量生效
echo.
echo Q: Visual Studio未检测到
echo A: 确保安装了"使用C++的桌面开发"工作负载
echo.
echo Q: 编译失败
echo A: 检查Visual Studio版本，建议使用VS 2022
echo.

echo ========================================
echo 下一步操作
echo ========================================
echo.
echo 1. 选择安装方案 (自动或手动)
echo 2. 完成安装后运行验证脚本
echo 3. 如果验证通过，您的环境就支持CUDA批量并行计算了！
echo.

pause
