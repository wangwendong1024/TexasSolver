@echo off
chcp 65001 >nul
echo ========================================
echo TexasSolver CUDA 11 专用测试运行脚本
echo ========================================
echo.

REM 检查CUDA 11环境
echo [1] 检查CUDA 11环境...
set "CUDA11_FOUND=0"

REM 查找CUDA 11.x版本
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
    echo 请先安装CUDA 11.x Toolkit
    echo 推荐版本: CUDA 11.8
    pause
    exit /b 1
)

echo [✓] CUDA 11.x 环境已就绪
echo.

REM 检查nvcc编译器
echo [2] 检查CUDA编译器...
if not exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" (
    echo [✗] nvcc编译器未找到
    echo 请确保CUDA Toolkit完整安装
    pause
    exit /b 1
)

echo [✓] nvcc编译器已找到
echo.

REM 检查Visual Studio环境
echo [3] 检查Visual Studio环境...
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
    echo [✗] Visual Studio未找到
    echo 请安装Visual Studio 2019/2022
    pause
    exit /b 1
)

echo [✓] Visual Studio环境已找到
echo.

REM 设置编译环境
echo [4] 设置编译环境...
call "%VS_PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Visual Studio环境设置失败
    pause
    exit /b 1
)

echo [✓] 编译环境设置成功
echo.

REM 检查测试程序文件
echo [5] 检查测试程序文件...
if not exist "texassolver_cuda11_test.cu" (
    echo [✗] 未找到TexasSolver CUDA 11测试程序
    echo 请确保 texassolver_cuda11_test.cu 文件存在
    pause
    exit /b 1
)

echo [✓] 测试程序文件已找到
echo.

REM 编译TexasSolver CUDA 11测试程序
echo [6] 编译TexasSolver CUDA 11测试程序...
echo 正在编译，请稍候...

"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA11_VERSION%\bin\nvcc.exe" ^
    -o texassolver_cuda11_test.exe ^
    texassolver_cuda11_test.cu ^
    -lcudart -lcublas ^
    -std=c++11 ^
    -O3 ^
    -arch=sm_60

if %errorlevel% neq 0 (
    echo [✗] TexasSolver CUDA 11测试程序编译失败
    echo.
    echo 可能的原因:
    echo 1. CUDA Toolkit安装不完整
    echo 2. Visual Studio环境配置问题
    echo 3. GPU计算能力不支持
    echo.
    echo 请检查错误信息并解决后重试
    pause
    exit /b 1
)

echo [✓] TexasSolver CUDA 11测试程序编译成功
echo.

REM 运行测试程序
echo [7] 运行TexasSolver CUDA 11性能测试...
echo ========================================
echo.

texassolver_cuda11_test.exe

if %errorlevel% neq 0 (
    echo.
    echo [✗] TexasSolver CUDA 11测试程序运行失败
    echo.
    echo 可能的原因:
    echo 1. GPU驱动问题
    echo 2. CUDA运行时库问题
    echo 3. GPU内存不足
    echo.
    echo 请检查错误信息并解决后重试
    pause
    exit /b 1
)

echo.
echo ========================================
echo [✓] TexasSolver CUDA 11性能测试完成
echo ========================================
echo.

REM 清理临时文件
echo [8] 清理临时文件...
if exist "texassolver_cuda11_test.exe" del texassolver_cuda11_test.exe
if exist "texassolver_cuda11_test.exp" del texassolver_cuda11_test.exp
if exist "texassolver_cuda11_test.lib" del texassolver_cuda11_test.lib

echo [✓] 临时文件清理完成
echo.

echo ========================================
echo 测试总结
echo ========================================
echo.
echo 如果上述测试全部通过，说明您的CUDA 11环境:
echo 1. ✓ 完全满足TexasSolver项目开发需求
echo 2. ✓ 具备高性能并行计算能力
echo 3. ✓ 支持cuBLAS矩阵运算加速
echo 4. ✓ GPU内存和计算能力充足
echo.
echo 建议:
echo 1. 可以开始TexasSolver项目的CUDA开发
echo 2. 建议安装cuDNN以获得更好的深度学习性能
echo 3. 定期更新NVIDIA驱动以获得最佳性能
echo 4. 对于大型问题，建议使用8GB以上GPU内存
echo.
echo 按任意键退出...
pause >nul
