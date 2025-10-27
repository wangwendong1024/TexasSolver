@echo off
chcp 65001 >nul
echo ========================================
echo CUDA + OpenMP 混合并行项目编译脚本 (简化版)
echo ========================================
echo.

echo 正在检查编译环境...
echo.

REM 检查CUDA环境
echo [1] 检查CUDA环境...
set "CUDA11_FOUND=0"
for %%v in (11.0 11.1 11.2 11.3 11.4 11.5 11.6 11.7 11.8) do (
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%%v" (
        echo [✓] 检测到CUDA %%v 安装
        set "CUDA11_FOUND=1"
        set "CUDA11_VERSION=%%v"
        goto :cuda11_found
    )
)

:cuda11_found
if %CUDA11_FOUND% equ 0 (
    echo [✗] 未检测到CUDA 11.x 安装
    echo 请先安装CUDA 11.x Toolkit
    pause
    exit /b 1
)

echo [✓] CUDA 11.x 环境已就绪
echo.

REM 设置环境变量
echo [2] 设置环境变量...
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%"
set "PATH=%CUDA_PATH%\bin;%PATH%"

echo [✓] 环境变量设置完成
echo.

REM 创建输出目录
echo [3] 创建输出目录...
if not exist "build" mkdir build

echo [✓] 输出目录创建完成
echo.

REM 编译CUDA+OpenMP测试程序 (使用nvcc直接编译)
echo [4] 编译CUDA+OpenMP测试程序...
echo 正在编译 cuda_openmp_test.cpp...

"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" ^
    -o build\cuda_openmp_test.exe ^
    cuda_openmp_test.cpp ^
    cuda_kernels.cu ^
    -lcudart -lcublas ^
    -std=c++17 ^
    -O3 ^
    -arch=sm_75 ^
    -Xcompiler "/openmp" ^
    -Xcompiler "/std:c++17"

if %errorlevel% neq 0 (
    echo [✗] CUDA+OpenMP测试程序编译失败
    echo.
    echo 可能的原因:
    echo 1. CUDA Toolkit安装不完整
    echo 2. 缺少必要的头文件
    echo 3. OpenMP支持问题
    echo.
    echo 请检查错误信息并解决后重试
    pause
    exit /b 1
)

echo [✓] CUDA+OpenMP测试程序编译成功
echo.

REM 复制CUDA运行时库
echo [5] 复制CUDA运行时库...
copy "%CUDA_PATH%\bin\cudart64_*.dll" "build\" >nul 2>&1
copy "%CUDA_PATH%\bin\cublas64_*.dll" "build\" >nul 2>&1

echo [✓] CUDA运行时库复制完成
echo.

REM 运行测试程序
echo [6] 运行CUDA+OpenMP测试程序...
echo ========================================
echo.

cd build
cuda_openmp_test.exe
cd ..

echo.
echo ========================================
echo [✓] CUDA+OpenMP测试程序运行完成
echo ========================================
echo.

echo ========================================
echo 编译完成！
echo ========================================
echo.

echo 生成的文件:
echo 1. build\cuda_openmp_test.exe - CUDA+OpenMP测试程序
echo.

echo 使用方法:
echo 1. 运行测试程序: build\cuda_openmp_test.exe
echo 2. 查看性能测试结果
echo.

echo 特性:
echo ✓ CUDA 11.x 支持
echo ✓ OpenMP 并行计算
echo ✓ 混合CPU+GPU计算
echo ✓ 优化的编译选项
echo ✓ 自动依赖管理
echo.

echo 按任意键退出...
pause >nul
