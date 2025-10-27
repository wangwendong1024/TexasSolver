@echo off
chcp 65001 >nul
echo CUDA Test Program Compilation and Execution Script
echo ================================================
echo.

REM Check CUDA environment
echo [1] Checking CUDA environment...
if not exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA" (
    echo [ERROR] CUDA not installed, cannot compile CUDA programs
    pause
    exit /b 1
)

REM 查找最新的CUDA版本
set "CUDA_PATH="
for /d %%i in ("C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\*") do (
    set "CUDA_PATH=%%i"
)

if "%CUDA_PATH%"=="" (
    echo ✗ 未找到CUDA安装路径
    pause
    exit /b 1
)

echo ✓ Found CUDA installation path: %CUDA_PATH%

REM 检查nvcc编译器
if not exist "%CUDA_PATH%\bin\nvcc.exe" (
    echo [ERROR] nvcc compiler not found
    pause
    exit /b 1
)

echo ✓ Found nvcc compiler: %CUDA_PATH%\bin\nvcc.exe

REM 检查Visual Studio
set "VS_PATH="
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
)

if "%VS_PATH%"=="" (
    echo [ERROR] Visual Studio not found
    pause
    exit /b 1
)

echo ✓ Found Visual Studio: %VS_PATH%

echo.
echo [2] Setting up compilation environment...
call "%VS_PATH%"

echo.
echo [3] Compiling CUDA test program...
"%CUDA_PATH%\bin\nvcc.exe" -o cuda_test.exe cuda_test.cu -lcudart
if %errorlevel% neq 0 (
    echo [ERROR] CUDA program compilation failed
    pause
    exit /b 1
)

echo ✓ CUDA program compiled successfully

echo.
echo [4] Running CUDA test program...
echo.
cuda_test.exe
if %errorlevel% neq 0 (
    echo [ERROR] CUDA program execution failed
    pause
    exit /b 1
)

echo.
echo ✓ CUDA test program executed successfully

echo.
echo [5] Cleaning temporary files...
if exist "cuda_test.exe" del cuda_test.exe
if exist "cuda_test.exp" del cuda_test.exp
if exist "cuda_test.lib" del cuda_test.lib

echo.
echo CUDA batch parallel computing test completed!
echo.
pause
