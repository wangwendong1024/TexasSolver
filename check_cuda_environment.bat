@echo off
chcp 65001 >nul
echo ========================================
echo CUDA环境检测脚本
echo ========================================
echo.

REM 检查NVIDIA GPU
echo [1] Checking NVIDIA GPU...
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] NVIDIA GPU detected
    echo.
    echo GPU Information:
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits
    echo.
) else (
    echo [ERROR] NVIDIA GPU not detected or nvidia-smi not available
    echo.
)

REM 检查CUDA安装
echo [2] Checking CUDA Installation...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" (
    echo [OK] CUDA installation directory detected
    for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
        echo   CUDA Version: %%~ni
    )
    echo.
) else (
    echo [ERROR] CUDA installation directory not found
    echo.
)

REM 检查CUDA环境变量
echo [3] Checking CUDA Environment Variables...
if defined CUDA_PATH (
    echo [OK] CUDA_PATH environment variable set: %CUDA_PATH%
) else (
    echo [ERROR] CUDA_PATH environment variable not set
)

if defined CUDA_PATH_V11_0 (
    echo [OK] CUDA_PATH_V11_0 environment variable set: %CUDA_PATH_V11_0%
) else if defined CUDA_PATH_V11_1 (
    echo [OK] CUDA_PATH_V11_1 environment variable set: %CUDA_PATH_V11_1%
) else if defined CUDA_PATH_V11_2 (
    echo [OK] CUDA_PATH_V11_2 environment variable set: %CUDA_PATH_V11_2%
) else if defined CUDA_PATH_V11_3 (
    echo [OK] CUDA_PATH_V11_3 environment variable set: %CUDA_PATH_V11_3%
) else if defined CUDA_PATH_V11_4 (
    echo [OK] CUDA_PATH_V11_4 environment variable set: %CUDA_PATH_V11_4%
) else if defined CUDA_PATH_V11_5 (
    echo [OK] CUDA_PATH_V11_5 environment variable set: %CUDA_PATH_V11_5%
) else if defined CUDA_PATH_V11_6 (
    echo [OK] CUDA_PATH_V11_6 environment variable set: %CUDA_PATH_V11_6%
) else if defined CUDA_PATH_V11_7 (
    echo [OK] CUDA_PATH_V11_7 environment variable set: %CUDA_PATH_V11_7%
) else if defined CUDA_PATH_V11_8 (
    echo [OK] CUDA_PATH_V11_8 environment variable set: %CUDA_PATH_V11_8%
) else if defined CUDA_PATH_V12_0 (
    echo [OK] CUDA_PATH_V12_0 environment variable set: %CUDA_PATH_V12_0%
) else if defined CUDA_PATH_V12_1 (
    echo [OK] CUDA_PATH_V12_1 environment variable set: %CUDA_PATH_V12_1%
) else if defined CUDA_PATH_V12_2 (
    echo [OK] CUDA_PATH_V12_2 environment variable set: %CUDA_PATH_V12_2%
) else if defined CUDA_PATH_V12_3 (
    echo [OK] CUDA_PATH_V12_3 environment variable set: %CUDA_PATH_V12_3%
) else if defined CUDA_PATH_V12_4 (
    echo [OK] CUDA_PATH_V12_4 environment variable set: %CUDA_PATH_V12_4%
) else if defined CUDA_PATH_V12_5 (
    echo [OK] CUDA_PATH_V12_5 environment variable set: %CUDA_PATH_V12_5%
) else if defined CUDA_PATH_V12_6 (
    echo [OK] CUDA_PATH_V12_6 environment variable set: %CUDA_PATH_V12_6%
) else (
    echo [ERROR] No CUDA version environment variables detected
)
echo.

REM 检查CUDA编译器
echo [4] Checking CUDA Compiler...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*\bin\nvcc.exe" (
    echo [OK] nvcc compiler detected
    for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
        if exist "%%i\bin\nvcc.exe" (
            echo   nvcc path: %%i\bin\nvcc.exe
            "%%i\bin\nvcc.exe" --version 2>nul | findstr "release"
        )
    )
) else (
    echo [ERROR] nvcc compiler not found
)
echo.

REM 检查CUDA运行时库
echo [5] Checking CUDA Runtime Libraries...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*\bin\cudart64_*.dll" (
    echo [OK] CUDA runtime libraries detected
    for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
        for %%j in ("%%i\bin\cudart64_*.dll") do (
            echo   CUDA Runtime: %%~nj
        )
    )
) else (
    echo [ERROR] CUDA runtime libraries not found
)
echo.

REM 检查cuBLAS库
echo [6] Checking cuBLAS Library...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*\bin\cublas64_*.dll" (
    echo [OK] cuBLAS library detected
    for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
        for %%j in ("%%i\bin\cublas64_*.dll") do (
            echo   cuBLAS Library: %%~nj
        )
    )
) else (
    echo [ERROR] cuBLAS library not found
)
echo.

REM 检查cuDNN库
echo [7] Checking cuDNN Library...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*\bin\cudnn64_*.dll" (
    echo [OK] cuDNN library detected
    for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
        for %%j in ("%%i\bin\cudnn64_*.dll") do (
            echo   cuDNN Library: %%~nj
        )
    )
) else (
    echo [ERROR] cuDNN library not found
)
echo.

REM 检查Visual Studio支持
echo [8] Checking Visual Studio Support...
if exist "C:\Program Files\Microsoft Visual Studio" (
    echo [OK] Visual Studio installation detected
    for /d %%i in ("C:\Program Files\Microsoft Visual Studio\*") do (
        echo   Visual Studio Version: %%~ni
    )
) else (
    echo [ERROR] Visual Studio installation not found
)
echo.

REM 检查MSBuild
echo [9] Checking MSBuild...
where msbuild >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] MSBuild available
    msbuild -version 2>nul | findstr "Microsoft"
) else (
    echo [ERROR] MSBuild not available
)
echo.

REM 检查OpenMP支持
echo [10] Checking OpenMP Support...
if exist "C:\Program Files\Microsoft Visual Studio\*\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe" (
    echo [OK] Visual Studio compiler detected
    echo    Supports OpenMP parallel computing
) else (
    echo [ERROR] Visual Studio compiler not found
)
echo.

REM 检查Python CUDA支持
echo [11] Checking Python CUDA Support...
python -c "import torch; print('PyTorch Version:', torch.__version__); print('CUDA Available:', torch.cuda.is_available()); print('CUDA Device Count:', torch.cuda.device_count())" 2>nul
if %errorlevel% equ 0 (
    echo [OK] Python CUDA support detection completed
) else (
    echo [ERROR] Python CUDA support detection failed or Python not installed
)
echo.

REM Summary
echo ========================================
echo Detection Summary
echo ========================================
echo.

REM Check key components
set "cuda_ready=0"
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" set /a cuda_ready+=1
nvidia-smi >nul 2>&1 && set /a cuda_ready+=1
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*\bin\nvcc.exe" set /a cuda_ready+=1

if %cuda_ready% geq 2 (
    echo [OK] CUDA environment is ready for development
    echo.
    echo Recommendations:
    echo 1. Ensure latest NVIDIA driver is installed
    echo 2. Install corresponding CUDA Toolkit version
    echo 3. Install cuDNN if needed for deep learning
    echo 4. Configure Visual Studio project to use CUDA compiler
) else (
    echo [ERROR] CUDA environment not ready
    echo.
    echo Required installations:
    echo 1. NVIDIA GPU driver
    echo 2. CUDA Toolkit
    echo 3. Visual Studio (for CUDA development)
)

echo.
echo Detection completed!
pause
