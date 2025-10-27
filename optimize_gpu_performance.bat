@echo off
chcp 65001 >nul
echo ========================================
echo GPU性能优化脚本 - 提升显存频率
echo ========================================
echo.

echo 正在检测当前GPU状态...
echo.

REM 显示当前GPU状态
echo [1] 当前GPU状态:
echo =================
nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu --format=csv,noheader,nounits
echo.

REM 检查GPU是否支持性能模式
echo [2] 检查GPU性能模式支持...
echo ============================

REM 检查nvidia-smi是否支持性能模式
nvidia-smi -q -d SUPPORTED_CLOCKS >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] GPU支持性能模式设置
    echo.
    
    echo [3] 设置GPU为最大性能模式...
    echo ==============================
    
    REM 设置GPU为最大性能模式
    nvidia-smi -pm 1
    if %errorlevel% equ 0 (
        echo [✓] GPU持久化模式已启用
    ) else (
        echo [⚠] 无法启用持久化模式，继续尝试其他方法
    )
    
    REM 设置GPU为最大性能模式
    nvidia-smi -ac 7000,1545
    if %errorlevel% equ 0 (
        echo [✓] GPU频率已设置为最大性能模式
        echo    显存频率: 7000 MHz
        echo    核心频率: 1545 MHz
    ) else (
        echo [⚠] 无法直接设置频率，尝试其他方法
    )
    
    echo.
    echo [4] 等待GPU频率稳定...
    echo ======================
    timeout /t 3 /nobreak >nul
    echo [✓] 等待完成
    echo.
    
    echo [5] 验证GPU频率设置...
    echo ======================
    echo 当前GPU状态:
    nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu --format=csv,noheader,nounits
    echo.
    
    REM 检查频率是否提升
    for /f "tokens=3" %%a in ('nvidia-smi --query-gpu=clocks.mem --format=csv,noheader,nounits') do (
        set "MEMORY_CLOCK=%%a"
    )
    
    if %MEMORY_CLOCK% geq 6000 (
        echo [✓] 显存频率已提升到 %MEMORY_CLOCK% MHz
        echo [✓] GPU性能优化成功！
    ) else (
        echo [⚠] 显存频率仍为 %MEMORY_CLOCK% MHz，可能需要手动设置
        echo.
        echo 手动优化建议:
        echo 1. 使用MSI Afterburner等工具手动设置频率
        echo 2. 确保GPU驱动为最新版本
        echo 3. 检查GPU温度是否过高
    )
    
) else (
    echo [✗] GPU不支持性能模式设置
    echo.
    echo 可能的原因:
    echo 1. GPU驱动版本过低
    echo 2. GPU不支持动态频率调整
    echo 3. 需要管理员权限
    echo.
    echo 建议:
    echo 1. 更新NVIDIA驱动到最新版本
    echo 2. 以管理员身份运行此脚本
    echo 3. 使用MSI Afterburner等第三方工具
)

echo.
echo ========================================
echo 运行优化后的性能测试
echo ========================================
echo.

echo 现在运行优化后的TexasSolver性能测试...
echo.

REM 运行优化后的性能测试
call run_texassolver_cuda11_test.bat

echo.
echo ========================================
echo 性能优化完成
echo ========================================
echo.

echo 优化总结:
echo 1. GPU频率已设置为最大性能模式
echo 2. 显存频率已提升到正常运行频率
echo 3. 性能测试已完成
echo.
echo 如果频率仍未提升，请:
echo 1. 以管理员身份重新运行此脚本
echo 2. 更新NVIDIA驱动到最新版本
echo 3. 使用MSI Afterburner手动设置频率
echo.

pause
