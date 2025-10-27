@echo off
chcp 65001 >nul
echo ========================================
echo CUDA + OpenMP 混合并行项目编译脚本
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

REM 检查Visual Studio环境
echo [2] 检查Visual Studio环境...
set "VS_PATH="
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)

if "%VS_PATH%"=="" (
    echo [✗] Visual Studio未找到
    echo 请安装Visual Studio 2019/2022
    pause
    exit /b 1
)

echo [✓] Visual Studio环境已找到
echo.

REM 设置编译环境
echo [3] 设置编译环境...
call "%VS_PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Visual Studio环境设置失败
    pause
    exit /b 1
)

echo [✓] 编译环境设置成功
echo.

REM 设置环境变量
echo [4] 设置环境变量...
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%"
set "PATH=%CUDA_PATH%\bin;%PATH%"
set "INCLUDE=%CUDA_PATH%\include;%INCLUDE%"
set "LIB=%CUDA_PATH%\lib\x64;%LIB%"

echo [✓] 环境变量设置完成
echo.

REM 创建输出目录
echo [5] 创建输出目录...
if not exist "build" mkdir build

echo [✓] 输出目录创建完成
echo.

REM 编译CUDA内核文件
echo [6] 编译CUDA内核文件...
echo 正在编译 cuda_kernels.cu...

"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" ^
    -c cuda_kernels.cu ^
    -o build\cuda_kernels.o ^
    -lcudart ^
    -std=c++17 ^
    -O3 ^
    -arch=sm_75

if %errorlevel% neq 0 (
    echo [✗] CUDA内核文件编译失败
    pause
    exit /b 1
)

echo [✓] CUDA内核文件编译成功
echo.

REM 编译CUDA+OpenMP测试程序
echo [7] 编译CUDA+OpenMP测试程序...
echo 正在编译 cuda_openmp_test.cpp...

cl.exe ^
    cuda_openmp_test.cpp ^
    build\cuda_kernels.o ^
    /Fe:build\cuda_openmp_test.exe ^
    /I"%CUDA_PATH%\include" ^
    /link ^
    "%CUDA_PATH%\lib\x64\cudart.lib" ^
    "%CUDA_PATH%\lib\x64\cublas.lib" ^
    /openmp ^
    /std:c++17 ^
    /O2

if %errorlevel% neq 0 (
    echo [✗] CUDA+OpenMP测试程序编译失败
    echo.
    echo 可能的原因:
    echo 1. CUDA Toolkit安装不完整
    echo 2. Visual Studio环境配置问题
    echo 3. OpenMP支持问题
    echo.
    echo 请检查错误信息并解决后重试
    pause
    exit /b 1
)

echo [✓] CUDA+OpenMP测试程序编译成功
echo.

REM 复制CUDA运行时库
echo [8] 复制CUDA运行时库...
copy "%CUDA_PATH%\bin\cudart64_*.dll" "build\" >nul 2>&1
copy "%CUDA_PATH%\bin\cublas64_*.dll" "build\" >nul 2>&1

echo [✓] CUDA运行时库复制完成
echo.

REM 运行测试程序
echo [9] 运行CUDA+OpenMP测试程序...
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
echo 2. build\cuda_kernels.o - CUDA内核对象文件
echo.

echo 使用方法:
echo 1. 运行测试程序: build\cuda_openmp_test.exe
echo 2. 查看性能测试结果
echo.

echo 特性:
echo ✓ CUDA 11.x 支持
echo ✓ OpenMP 并行计算
echo ✓ 混合CPU+GPU计算
echo ✓ Visual Studio 2019/2022 支持
echo ✓ 优化的编译选项
echo ✓ 自动依赖管理
echo.

echo 按任意键退出...
pause >nul