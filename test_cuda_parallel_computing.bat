@echo off
chcp 65001 >nul
echo ========================================
echo CUDA Batch Parallel Computing Environment Detection and Testing
echo ========================================
echo.

echo Detecting CUDA environment...
call check_cuda_environment.bat

echo.
echo ========================================
echo Starting CUDA Computing Capability Test
echo ========================================
echo.

echo Compiling and running CUDA test program...
call run_cuda_test.bat

echo.
echo ========================================
echo Detection and Testing Completed
echo ========================================
echo.

echo If all tests above pass, your Windows environment supports CUDA batch parallel computing!
echo.
echo Recommendations:
echo 1. Ensure NVIDIA driver is up to date
echo 2. Install complete CUDA Toolkit
echo 3. Configure Visual Studio project to use CUDA compiler
echo 4. For deep learning projects, recommend installing cuDNN
echo.

pause
