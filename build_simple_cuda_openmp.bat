@echo off
chcp 65001 >nul
echo ========================================
echo Simple CUDA + OpenMP Test Compilation
echo ========================================
echo.

echo Checking compilation environment...
echo.

REM Check CUDA environment
echo [1] Checking CUDA environment...
set "CUDA11_FOUND=0"
for %%v in (11.0 11.1 11.2 11.3 11.4 11.5 11.6 11.7 11.8) do (
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%%v" (
        echo [✓] Detected CUDA %%v installation
        set "CUDA11_FOUND=1"
        set "CUDA11_VERSION=%%v"
        goto :cuda11_found
    )
)

:cuda11_found
if %CUDA11_FOUND% equ 0 (
    echo [✗] CUDA 11.x installation not detected
    echo Please install CUDA 11.x Toolkit first
    pause
    exit /b 1
)

echo [✓] CUDA 11.x environment ready
echo.

REM Set environment variables
echo [2] Setting environment variables...
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%"
set "PATH=%CUDA_PATH%\bin;%PATH%"

echo [✓] Environment variables set
echo.

REM Create output directory
echo [3] Creating output directory...
if not exist "build" mkdir build

echo [✓] Output directory created
echo.

REM Compile CUDA+OpenMP test program
echo [4] Compiling CUDA+OpenMP test program...
echo Compiling simple_cuda_openmp_test.cu...

"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" ^
    -o build\simple_cuda_openmp_test.exe ^
    simple_cuda_openmp_test.cu ^
    cuda_kernels.cu ^
    -lcudart -lcublas ^
    -std=c++17 ^
    -O3 ^
    -arch=sm_75 ^
    -Xcompiler "/openmp" ^
    -Xcompiler "/std:c++17"

if %errorlevel% neq 0 (
    echo [✗] CUDA+OpenMP test program compilation failed
    echo.
    echo Possible reasons:
    echo 1. CUDA Toolkit installation incomplete
    echo 2. Missing necessary header files
    echo 3. OpenMP support issues
    echo.
    echo Please check error messages and resolve before retrying
    pause
    exit /b 1
)

echo [✓] CUDA+OpenMP test program compiled successfully
echo.

REM Copy CUDA runtime libraries
echo [5] Copying CUDA runtime libraries...
copy "%CUDA_PATH%\bin\cudart64_*.dll" "build\" >nul 2>&1
copy "%CUDA_PATH%\bin\cublas64_*.dll" "build\" >nul 2>&1

echo [✓] CUDA runtime libraries copied
echo.

REM Run test program
echo [6] Running CUDA+OpenMP test program...
echo ========================================
echo.

cd build
simple_cuda_openmp_test.exe
cd ..

echo.
echo ========================================
echo [✓] CUDA+OpenMP test program completed
echo ========================================
echo.

echo ========================================
echo Compilation completed!
echo ========================================
echo.

echo Generated files:
echo 1. build\simple_cuda_openmp_test.exe - CUDA+OpenMP test program
echo.

echo Usage:
echo 1. Run test program: build\simple_cuda_openmp_test.exe
echo 2. View performance test results
echo.

echo Features:
echo ✓ CUDA 11.x support
echo ✓ OpenMP parallel computing
echo ✓ Hybrid CPU+GPU computing
echo ✓ Optimized compilation options
echo ✓ Automatic dependency management
echo.

echo Press any key to exit...
pause >nul