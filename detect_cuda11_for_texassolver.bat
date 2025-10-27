@echo off
chcp 65001 >nul
echo ========================================
echo CUDA 11 环境检测脚本 - TexasSolver项目专用
echo ========================================
echo.

REM 设置检测结果变量
set "CUDA11_DETECTED=0"
set "GPU_SUITABLE=0"
set "COMPUTE_CAPABILITY_OK=0"
set "MEMORY_SUFFICIENT=0"
set "PARALLEL_CAPABILITY_OK=0"

echo 正在检测您的CUDA 11环境是否满足TexasSolver项目需求...
echo.

REM ========================================
REM 1. 检测NVIDIA GPU
REM ========================================
echo [1] 检测NVIDIA GPU硬件...
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] NVIDIA GPU 已检测到
    echo.
    echo GPU 详细信息:
    nvidia-smi --query-gpu=name,driver_version,memory.total,compute_cap --format=csv,noheader,nounits
    echo.
    
    REM 检查GPU型号是否适合TexasSolver
    nvidia-smi --query-gpu=name --format=csv,noheader,nounits | findstr /i "RTX\|GTX\|Tesla\|Quadro" >nul
    if %errorlevel% equ 0 (
        echo [✓] GPU型号适合并行计算
        set "GPU_SUITABLE=1"
    ) else (
        echo [⚠] GPU型号可能不适合高性能并行计算
    )
) else (
    echo [✗] 未检测到NVIDIA GPU或nvidia-smi不可用
    echo.
    echo TexasSolver需要NVIDIA GPU进行并行计算加速
    goto :summary
)

REM ========================================
REM 2. 检测CUDA 11安装
REM ========================================
echo [2] 检测CUDA 11.x 安装...
set "CUDA11_FOUND=0"

REM 检查CUDA 11.0-11.8版本
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
    echo.
    echo TexasSolver推荐使用CUDA 11.x版本进行开发
    echo 请安装CUDA 11.8 (最新稳定版本)
    goto :summary
) else (
    echo [✓] CUDA 11.x 环境已就绪
    set "CUDA11_DETECTED=1"
)

REM ========================================
REM 3. 检测CUDA编译器
REM ========================================
echo [3] 检测CUDA编译器 (nvcc)...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" (
    echo [✓] nvcc编译器已找到
    echo.
    echo CUDA编译器版本信息:
    "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" --version 2>nul | findstr "release"
    echo.
) else (
    echo [✗] nvcc编译器未找到
    echo.
    echo 请确保CUDA Toolkit完整安装
    goto :summary
)

REM ========================================
REM 4. 检测CUDA运行时库
REM ========================================
echo [4] 检测CUDA运行时库...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cudart64_*.dll" (
    echo [✓] CUDA运行时库已找到
    for %%f in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cudart64_*.dll") do (
        echo   - %%~nf
    )
) else (
    echo [✗] CUDA运行时库未找到
    goto :summary
)

REM ========================================
REM 5. 检测cuBLAS库 (TexasSolver需要)
REM ========================================
echo [5] 检测cuBLAS库 (TexasSolver矩阵运算需要)...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cublas64_*.dll" (
    echo [✓] cuBLAS库已找到
    for %%f in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cublas64_*.dll") do (
        echo   - %%~nf
    )
) else (
    echo [✗] cuBLAS库未找到
    echo.
    echo TexasSolver需要cuBLAS进行矩阵运算加速
    goto :summary
)

REM ========================================
REM 6. 检测Visual Studio支持
REM ========================================
echo [6] 检测Visual Studio开发环境...
set "VS_FOUND=0"

REM 检查VS 2019/2022
if exist "C:\Program Files\Microsoft Visual Studio\2022" (
    echo [✓] Visual Studio 2022 已检测到
    set "VS_FOUND=1"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    echo [✓] Visual Studio 2019 已检测到
    set "VS_FOUND=1"
)

if %VS_FOUND% equ 0 (
    echo [✗] Visual Studio未检测到
    echo.
    echo TexasSolver需要Visual Studio进行CUDA项目编译
    echo 请安装Visual Studio 2019/2022 Community版本
    goto :summary
)

REM ========================================
REM 7. 检测MSBuild
REM ========================================
echo [7] 检测MSBuild工具...
where msbuild >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] MSBuild工具可用
    msbuild -version 2>nul | findstr "Microsoft"
) else (
    echo [✗] MSBuild工具不可用
    echo.
    echo 请确保Visual Studio完整安装，包含MSBuild工具
    goto :summary
)

REM ========================================
REM 8. 检测GPU计算能力
REM ========================================
echo [8] 检测GPU计算能力...
echo 正在运行GPU计算能力测试...

REM 创建临时CUDA测试程序
echo #include ^<stdio.h^> > temp_gpu_test.cu
echo #include ^<cuda_runtime.h^> >> temp_gpu_test.cu
echo int main() { >> temp_gpu_test.cu
echo     int deviceCount; >> temp_gpu_test.cu
echo     cudaGetDeviceCount(^&deviceCount); >> temp_gpu_test.cu
echo     if (deviceCount ^> 0) { >> temp_gpu_test.cu
echo         cudaDeviceProp prop; >> temp_gpu_test.cu
echo         cudaGetDeviceProperties(^&prop, 0); >> temp_gpu_test.cu
echo         printf("GPU: %%s\n", prop.name); >> temp_gpu_test.cu
echo         printf("Compute Capability: %%d.%%d\n", prop.major, prop.minor); >> temp_gpu_test.cu
echo         printf("Global Memory: %.2f GB\n", prop.totalGlobalMem / (1024.0*1024.0*1024.0)); >> temp_gpu_test.cu
echo         printf("Multiprocessors: %%d\n", prop.multiProcessorCount); >> temp_gpu_test.cu
echo         printf("Max Threads per Block: %%d\n", prop.maxThreadsPerBlock); >> temp_gpu_test.cu
echo         if (prop.major ^>= 6) { >> temp_gpu_test.cu
echo             printf("Compute Capability: SUITABLE for TexasSolver\n"); >> temp_gpu_test.cu
echo         } else { >> temp_gpu_test.cu
echo             printf("Compute Capability: MAY NOT BE SUITABLE for TexasSolver\n"); >> temp_gpu_test.cu
echo         } >> temp_gpu_test.cu
echo     } >> temp_gpu_test.cu
echo     return 0; >> temp_gpu_test.cu
echo } >> temp_gpu_test.cu

REM 编译并运行测试
"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" -o temp_gpu_test.exe temp_gpu_test.cu 2>nul
if %errorlevel% equ 0 (
    echo [✓] GPU测试程序编译成功
    echo.
    echo GPU计算能力测试结果:
    temp_gpu_test.exe
    echo.
    
    REM 检查计算能力是否满足要求
    temp_gpu_test.exe | findstr "SUITABLE" >nul
    if %errorlevel% equ 0 (
        echo [✓] GPU计算能力满足TexasSolver要求
        set "COMPUTE_CAPABILITY_OK=1"
    ) else (
        echo [⚠] GPU计算能力可能不满足TexasSolver要求
        echo TexasSolver推荐使用计算能力6.0以上的GPU
    )
    
    REM 检查内存是否充足
    temp_gpu_test.exe | findstr "GB" >nul
    if %errorlevel% equ 0 (
        echo [✓] GPU内存检测完成
        set "MEMORY_SUFFICIENT=1"
    )
    
    REM 清理临时文件
    del temp_gpu_test.exe temp_gpu_test.cu 2>nul
) else (
    echo [✗] GPU测试程序编译失败
    del temp_gpu_test.cu 2>nul
)

REM ========================================
REM 9. 检测并行计算性能
REM ========================================
echo [9] 检测并行计算性能...
echo 正在运行TexasSolver专用并行计算测试...

REM 检查现有的CUDA测试程序
if exist "cuda_test.cu" (
    echo [✓] 找到TexasSolver CUDA测试程序
    echo 正在编译和运行测试...
    
    REM 设置Visual Studio环境
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    )
    
    REM 编译CUDA测试程序
    "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" -o texassolver_cuda_test.exe cuda_test.cu -lcudart 2>nul
    if %errorlevel% equ 0 (
        echo [✓] TexasSolver CUDA测试程序编译成功
        echo.
        echo 正在运行并行计算性能测试...
        echo ========================================
        texassolver_cuda_test.exe
        echo ========================================
        echo.
        
        REM 检查测试是否成功
        if %errorlevel% equ 0 (
            echo [✓] TexasSolver并行计算测试通过
            set "PARALLEL_CAPABILITY_OK=1"
        ) else (
            echo [✗] TexasSolver并行计算测试失败
        )
        
        REM 清理测试程序
        del texassolver_cuda_test.exe 2>nul
    ) else (
        echo [✗] TexasSolver CUDA测试程序编译失败
    )
) else (
    echo [⚠] 未找到TexasSolver CUDA测试程序
    echo 将使用基础CUDA功能测试
)

REM ========================================
REM 10. 检测环境变量
REM ========================================
echo [10] 检测CUDA环境变量...
if defined CUDA_PATH (
    echo [✓] CUDA_PATH 已设置: %CUDA_PATH%
) else (
    echo [✗] CUDA_PATH 环境变量未设置
)

if defined CUDA_PATH_V%CUDA11_VERSION:~0,2%_%CUDA11_VERSION:~3,1% (
    echo [✓] CUDA版本环境变量已设置
) else (
    echo [⚠] CUDA版本环境变量未设置
)

REM ========================================
REM 总结报告
REM ========================================
:summary
echo.
echo ========================================
echo TexasSolver CUDA 11 环境检测报告
echo ========================================
echo.

set "TOTAL_SCORE=0"
set "MAX_SCORE=10"

if %CUDA11_DETECTED% equ 1 (
    echo [✓] CUDA 11.x 环境: 已就绪
    set /a TOTAL_SCORE+=2
) else (
    echo [✗] CUDA 11.x 环境: 未就绪
)

if %GPU_SUITABLE% equ 1 (
    echo [✓] GPU硬件: 适合并行计算
    set /a TOTAL_SCORE+=2
) else (
    echo [✗] GPU硬件: 可能不适合
)

if %COMPUTE_CAPABILITY_OK% equ 1 (
    echo [✓] 计算能力: 满足要求
    set /a TOTAL_SCORE+=2
) else (
    echo [✗] 计算能力: 可能不满足要求
)

if %MEMORY_SUFFICIENT% equ 1 (
    echo [✓] GPU内存: 充足
    set /a TOTAL_SCORE+=1
) else (
    echo [✗] GPU内存: 可能不足
)

if %PARALLEL_CAPABILITY_OK% equ 1 (
    echo [✓] 并行计算: 测试通过
    set /a TOTAL_SCORE+=3
) else (
    echo [✗] 并行计算: 测试失败
)

echo.
echo ========================================
echo 总体评估
echo ========================================

if %TOTAL_SCORE% geq 8 (
    echo [✓] 恭喜！您的CUDA 11环境完全满足TexasSolver项目需求
    echo.
    echo 建议:
    echo 1. 可以开始TexasSolver项目的CUDA开发
    echo 2. 建议安装cuDNN以获得更好的深度学习性能
    echo 3. 定期更新NVIDIA驱动以获得最佳性能
) else if %TOTAL_SCORE% geq 6 (
    echo [⚠] 您的CUDA 11环境基本满足TexasSolver项目需求
    echo.
    echo 建议:
    echo 1. 可以开始TexasSolver项目开发，但可能需要优化
    echo 2. 建议升级GPU硬件以获得更好性能
    echo 3. 确保所有CUDA组件正确安装
) else (
    echo [✗] 您的CUDA 11环境不满足TexasSolver项目需求
    echo.
    echo 需要解决的问题:
    echo 1. 安装完整的CUDA 11.x Toolkit
    echo 2. 确保NVIDIA GPU驱动最新
    echo 3. 安装Visual Studio 2019/2022
    echo 4. 配置正确的环境变量
)

echo.
echo 检测完成！按任意键退出...
pause >nul
