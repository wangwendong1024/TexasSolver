@echo off
chcp 65001 >nul
echo ========================================
echo TexasSolver CUDA 11 环境检测与优化建议
echo ========================================
echo.

echo 正在全面检测您的CUDA 11环境...
echo 本脚本将评估您的系统是否满足TexasSolver项目需求
echo.

REM 设置检测结果变量
set "OVERALL_SCORE=0"
set "MAX_SCORE=100"

REM ========================================
REM 1. 基础硬件检测
REM ========================================
echo [1] 基础硬件检测
echo ==================

REM 检测NVIDIA GPU
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] NVIDIA GPU 已检测到
    echo.
    echo GPU 详细信息:
    nvidia-smi --query-gpu=name,driver_version,memory.total,compute_cap --format=csv,noheader,nounits
    echo.
    
    REM 检查GPU型号
    nvidia-smi --query-gpu=name --format=csv,noheader,nounits | findstr /i "RTX\|GTX\|Tesla\|Quadro" >nul
    if %errorlevel% equ 0 (
        echo [✓] GPU型号适合并行计算 (+10分)
        set /a OVERALL_SCORE+=10
    ) else (
        echo [⚠] GPU型号可能不适合高性能并行计算
    )
    
    REM 检查GPU内存
    for /f "tokens=3" %%a in ('nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits') do (
        set "GPU_MEMORY=%%a"
    )
    
    if %GPU_MEMORY% geq 8192 (
        echo [✓] GPU内存充足 (8GB+) (+15分)
        set /a OVERALL_SCORE+=15
    ) else if %GPU_MEMORY% geq 4096 (
        echo [✓] GPU内存基本充足 (4GB+) (+10分)
        set /a OVERALL_SCORE+=10
    ) else (
        echo [⚠] GPU内存可能不足 (4GB以下)
    )
) else (
    echo [✗] 未检测到NVIDIA GPU (-30分)
    set /a OVERALL_SCORE-=30
)

echo.

REM ========================================
REM 2. CUDA 11环境检测
REM ========================================
echo [2] CUDA 11环境检测
echo ====================

set "CUDA11_FOUND=0"
for %%v in (11.0 11.1 11.2 11.3 11.4 11.5 11.6 11.7 11.8) do (
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%%v" (
        echo [✓] 检测到CUDA %%v 安装 (+20分)
        set "CUDA11_FOUND=1"
        set "CUDA11_VERSION=%%v"
        set /a OVERALL_SCORE+=20
        goto :cuda11_found
    )
)

:cuda11_found
if %CUDA11_FOUND% equ 0 (
    echo [✗] 未检测到CUDA 11.x 安装 (-20分)
    set /a OVERALL_SCORE-=20
)

REM 检查nvcc编译器
if %CUDA11_FOUND% equ 1 (
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" (
        echo [✓] nvcc编译器已找到 (+10分)
        set /a OVERALL_SCORE+=10
        
        echo CUDA编译器版本:
        "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" --version 2>nul | findstr "release"
    ) else (
        echo [✗] nvcc编译器未找到 (-10分)
        set /a OVERALL_SCORE-=10
    )
)

echo.

REM ========================================
REM 3. CUDA库检测
REM ========================================
echo [3] CUDA库检测
echo ===============

if %CUDA11_FOUND% equ 1 (
    REM 检查CUDA运行时库
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cudart64_*.dll" (
        echo [✓] CUDA运行时库已找到 (+5分)
        set /a OVERALL_SCORE+=5
    ) else (
        echo [✗] CUDA运行时库未找到 (-5分)
        set /a OVERALL_SCORE-=5
    )
    
    REM 检查cuBLAS库
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cublas64_*.dll" (
        echo [✓] cuBLAS库已找到 (+10分)
        set /a OVERALL_SCORE+=10
    ) else (
        echo [✗] cuBLAS库未找到 (-10分)
        set /a OVERALL_SCORE-=10
    )
    
    REM 检查cuDNN库
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\cudnn64_*.dll" (
        echo [✓] cuDNN库已找到 (+5分)
        set /a OVERALL_SCORE+=5
    ) else (
        echo [⚠] cuDNN库未找到 (可选)
    )
) else (
    echo [✗] 无法检测CUDA库 (CUDA未安装)
)

echo.

REM ========================================
REM 4. 开发环境检测
REM ========================================
echo [4] 开发环境检测
echo =================

REM 检查Visual Studio
set "VS_FOUND=0"
if exist "C:\Program Files\Microsoft Visual Studio\2022" (
    echo [✓] Visual Studio 2022 已检测到 (+15分)
    set "VS_FOUND=1"
    set /a OVERALL_SCORE+=15
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    echo [✓] Visual Studio 2019 已检测到 (+10分)
    set "VS_FOUND=1"
    set /a OVERALL_SCORE+=10
)

if %VS_FOUND% equ 0 (
    echo [✗] Visual Studio未检测到 (-15分)
    set /a OVERALL_SCORE-=15
)

REM 检查MSBuild
where msbuild >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] MSBuild工具可用 (+5分)
    set /a OVERALL_SCORE+=5
) else (
    echo [✗] MSBuild工具不可用 (-5分)
    set /a OVERALL_SCORE-=5
)

echo.

REM ========================================
REM 5. 环境变量检测
REM ========================================
echo [5] 环境变量检测
echo =================

if defined CUDA_PATH (
    echo [✓] CUDA_PATH 已设置 (+5分)
    set /a OVERALL_SCORE+=5
) else (
    echo [✗] CUDA_PATH 环境变量未设置 (-5分)
    set /a OVERALL_SCORE-=5
)

if %CUDA11_FOUND% equ 1 (
    if defined CUDA_PATH_V%CUDA11_VERSION:~0,2%_%CUDA11_VERSION:~3,1% (
        echo [✓] CUDA版本环境变量已设置 (+5分)
        set /a OVERALL_SCORE+=5
    ) else (
        echo [⚠] CUDA版本环境变量未设置
    )
)

echo.

REM ========================================
REM 6. 性能测试
REM ========================================
echo [6] 性能测试
echo =============

if %CUDA11_FOUND% equ 1 (
    echo 正在运行TexasSolver专用性能测试...
    echo.
    
    REM 检查是否有测试程序
    if exist "texassolver_cuda11_test.cu" (
        echo [✓] 找到TexasSolver专用测试程序
        echo 正在编译和运行测试...
        
        REM 设置Visual Studio环境
        if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
            call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
        ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
            call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
        )
        
        REM 编译测试程序
        "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" -o texassolver_cuda11_test.exe texassolver_cuda11_test.cu -lcudart -lcublas -std=c++11 -O3 -arch=sm_60 2>nul
        
        if %errorlevel% equ 0 (
            echo [✓] 测试程序编译成功 (+10分)
            set /a OVERALL_SCORE+=10
            
            echo 正在运行性能测试...
            echo ========================================
            texassolver_cuda11_test.exe
            echo ========================================
            
            if %errorlevel% equ 0 (
                echo [✓] 性能测试通过 (+15分)
                set /a OVERALL_SCORE+=15
            ) else (
                echo [✗] 性能测试失败 (-10分)
                set /a OVERALL_SCORE-=10
            )
            
            REM 清理测试程序
            del texassolver_cuda11_test.exe 2>nul
        ) else (
            echo [✗] 测试程序编译失败 (-10分)
            set /a OVERALL_SCORE-=10
        )
    ) else (
        echo [⚠] 未找到TexasSolver专用测试程序
        echo 将运行基础CUDA功能测试...
        
        REM 创建基础测试程序
        echo #include ^<stdio.h^> > basic_cuda_test.cu
        echo #include ^<cuda_runtime.h^> >> basic_cuda_test.cu
        echo int main() { >> basic_cuda_test.cu
        echo     int deviceCount; >> basic_cuda_test.cu
        echo     cudaGetDeviceCount(^&deviceCount); >> basic_cuda_test.cu
        echo     if (deviceCount ^> 0) { >> basic_cuda_test.cu
        echo         cudaDeviceProp prop; >> basic_cuda_test.cu
        echo         cudaGetDeviceProperties(^&prop, 0); >> basic_cuda_test.cu
        echo         printf("GPU: %%s\n", prop.name); >> basic_cuda_test.cu
        echo         printf("Compute Capability: %%d.%%d\n", prop.major, prop.minor); >> basic_cuda_test.cu
        echo         printf("Global Memory: %.2f GB\n", prop.totalGlobalMem / (1024.0*1024.0*1024.0)); >> basic_cuda_test.cu
        echo         printf("Multiprocessors: %%d\n", prop.multiProcessorCount); >> basic_cuda_test.cu
        echo         if (prop.major ^>= 6) { >> basic_cuda_test.cu
        echo             printf("Compute Capability: SUITABLE for TexasSolver\n"); >> basic_cuda_test.cu
        echo         } else { >> basic_cuda_test.cu
        echo             printf("Compute Capability: MAY NOT BE SUITABLE for TexasSolver\n"); >> basic_cuda_test.cu
        echo         } >> basic_cuda_test.cu
        echo     } >> basic_cuda_test.cu
        echo     return 0; >> basic_cuda_test.cu
        echo } >> basic_cuda_test.cu
        
        "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" -o basic_cuda_test.exe basic_cuda_test.cu 2>nul
        
        if %errorlevel% equ 0 (
            echo [✓] 基础测试程序编译成功 (+5分)
            set /a OVERALL_SCORE+=5
            
            echo 基础CUDA功能测试结果:
            basic_cuda_test.exe
            
            basic_cuda_test.exe | findstr "SUITABLE" >nul
            if %errorlevel% equ 0 (
                echo [✓] GPU计算能力满足TexasSolver要求 (+10分)
                set /a OVERALL_SCORE+=10
            ) else (
                echo [⚠] GPU计算能力可能不满足TexasSolver要求
            )
            
            del basic_cuda_test.exe basic_cuda_test.cu 2>nul
        ) else (
            echo [✗] 基础测试程序编译失败
            del basic_cuda_test.cu 2>nul
        )
    )
) else (
    echo [✗] 无法运行性能测试 (CUDA未安装)
)

echo.

REM ========================================
REM 7. 综合评估和建议
REM ========================================
echo [7] 综合评估和建议
echo ===================

echo ========================================
echo TexasSolver CUDA 11 环境评估报告
echo ========================================
echo.

echo 总体评分: %OVERALL_SCORE%/100
echo.

if %OVERALL_SCORE% geq 90 (
    echo [✓] 优秀！您的CUDA 11环境完全满足TexasSolver项目需求
    echo.
    echo 优势:
    echo - GPU硬件性能优秀
    echo - CUDA 11环境配置完整
    echo - 开发工具齐全
    echo - 性能测试通过
    echo.
    echo 建议:
    echo 1. 可以立即开始TexasSolver项目的CUDA开发
    echo 2. 建议安装cuDNN以获得更好的深度学习性能
    echo 3. 定期更新NVIDIA驱动以获得最佳性能
    echo 4. 考虑使用多GPU并行计算以提升性能
) else if %OVERALL_SCORE% geq 70 (
    echo [✓] 良好！您的CUDA 11环境基本满足TexasSolver项目需求
    echo.
    echo 优势:
    echo - CUDA 11环境基本就绪
    echo - 主要组件已安装
    echo.
    echo 需要改进的地方:
    if %OVERALL_SCORE% lss 80 (
        echo - 建议升级GPU硬件以获得更好性能
    )
    if %OVERALL_SCORE% lss 85 (
        echo - 建议安装cuDNN库
    )
    echo - 确保所有CUDA组件正确安装
    echo.
    echo 建议:
    echo 1. 可以开始TexasSolver项目开发，但可能需要优化
    echo 2. 建议升级GPU硬件以获得更好性能
    echo 3. 确保所有CUDA组件正确安装
) else if %OVERALL_SCORE% geq 50 (
    echo [⚠] 一般！您的CUDA 11环境部分满足TexasSolver项目需求
    echo.
    echo 主要问题:
    echo - CUDA环境配置不完整
    echo - 缺少必要的开发工具
    echo - 性能可能不满足要求
    echo.
    echo 需要解决的问题:
    echo 1. 安装完整的CUDA 11.x Toolkit
    echo 2. 确保NVIDIA GPU驱动最新
    echo 3. 安装Visual Studio 2019/2022
    echo 4. 配置正确的环境变量
    echo 5. 安装cuBLAS和cuDNN库
    echo.
    echo 建议:
    echo 1. 先解决上述问题，再进行TexasSolver项目开发
    echo 2. 建议升级GPU硬件以获得更好性能
) else (
    echo [✗] 不足！您的CUDA 11环境不满足TexasSolver项目需求
    echo.
    echo 主要问题:
    echo - CUDA环境未正确安装
    echo - 缺少必要的开发工具
    echo - GPU硬件可能不适合
    echo.
    echo 必须解决的问题:
    echo 1. 安装NVIDIA GPU驱动
    echo 2. 安装完整的CUDA 11.x Toolkit
    echo 3. 安装Visual Studio 2019/2022
    echo 4. 配置正确的环境变量
    echo 5. 安装cuBLAS和cuDNN库
    echo 6. 考虑升级GPU硬件
    echo.
    echo 建议:
    echo 1. 先解决上述问题，再进行TexasSolver项目开发
    echo 2. 建议使用RTX 3060或更高性能的GPU
)

echo.
echo ========================================
echo 具体优化建议
echo ========================================
echo.

echo 1. GPU硬件优化:
echo    - 推荐使用RTX 3060或更高性能的GPU
echo    - 建议GPU内存至少4GB，推荐8GB以上
echo    - 确保GPU计算能力在6.0以上
echo.

echo 2. CUDA环境优化:
echo    - 使用CUDA 11.8 (最新稳定版本)
echo    - 确保CUDA Toolkit完整安装
echo    - 安装cuBLAS和cuDNN库
echo    - 配置正确的环境变量
echo.

echo 3. 开发环境优化:
echo    - 使用Visual Studio 2022 Community
echo    - 确保MSBuild工具可用
echo    - 配置CUDA项目设置
echo.

echo 4. 性能优化:
echo    - 定期更新NVIDIA驱动
echo    - 使用最新的CUDA版本
echo    - 考虑多GPU并行计算
echo    - 优化内存使用
echo.

echo 5. TexasSolver项目特定建议:
echo    - 对于大型问题，建议使用8GB以上GPU内存
echo    - 建议安装cuDNN以获得更好的深度学习性能
echo    - 考虑使用混合精度计算以提升性能
echo    - 优化CFR算法的并行实现
echo.

echo ========================================
echo 检测完成！
echo ========================================
echo.

echo 如需运行详细性能测试，请执行:
echo run_texassolver_cuda11_test.bat
echo.

echo 如需安装CUDA 11.8，请执行:
echo cuda_12_6_installation_guide.bat
echo.

echo 按任意键退出...
pause >nul
