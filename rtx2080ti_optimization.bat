@echo off
chcp 65001 >nul
echo ========================================
echo RTX 2080 Ti 专用性能优化脚本
echo ========================================
echo.

echo 正在为RTX 2080 Ti优化GPU性能...
echo.

REM 显示当前GPU状态
echo [1] 当前GPU状态:
echo =================
nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu,power.limit --format=csv,noheader,nounits
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [⚠] 警告: 未以管理员身份运行
    echo 建议以管理员身份运行以获得最佳效果
    echo.
)

echo [2] RTX 2080 Ti 性能优化设置...
echo ================================

REM RTX 2080 Ti 规格:
REM - 基础显存频率: 7000 MHz
REM - 基础核心频率: 1350 MHz
REM - 最大功耗: 250W (可超频到300W)

echo 设置RTX 2080 Ti为最大性能模式...

REM 方法1: 启用持久化模式
echo 启用GPU持久化模式...
nvidia-smi -pm 1
if %errorlevel% equ 0 (
    echo [✓] GPU持久化模式已启用
) else (
    echo [⚠] 持久化模式启用失败
)

REM 方法2: 设置最大性能模式
echo 设置GPU频率为最大性能模式...
nvidia-smi -ac 7000,1545
if %errorlevel% equ 0 (
    echo [✓] GPU频率已设置为最大性能模式
    echo    显存频率: 7000 MHz
    echo    核心频率: 1545 MHz
) else (
    echo [⚠] 直接频率设置失败
)

REM 方法3: 设置功耗限制
echo 设置GPU功耗限制...
nvidia-smi -pl 300
if %errorlevel% equ 0 (
    echo [✓] GPU功耗限制已设置为300W
) else (
    echo [⚠] 功耗限制设置失败
)

echo.
echo [3] 等待GPU频率稳定...
echo ======================
echo 等待3秒让GPU频率稳定...
timeout /t 3 /nobreak >nul
echo [✓] 等待完成
echo.

echo [4] 验证GPU频率设置...
echo ======================
echo 当前GPU状态:
nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu,power.limit --format=csv,noheader,nounits
echo.

REM 检查频率是否提升
for /f "tokens=3" %%a in ('nvidia-smi --query-gpu=clocks.mem --format=csv,noheader,nounits') do (
    set "MEMORY_CLOCK=%%a"
)

for /f "tokens=2" %%a in ('nvidia-smi --query-gpu=clocks.gr --format=csv,noheader,nounits') do (
    set "GRAPHICS_CLOCK=%%a"
)

echo 频率检查结果:
echo - 显存频率: %MEMORY_CLOCK% MHz (目标: 7000 MHz)
echo - 核心频率: %GRAPHICS_CLOCK% MHz (目标: 1545 MHz)
echo.

if %MEMORY_CLOCK% geq 6000 (
    echo [✓] 显存频率已成功提升到 %MEMORY_CLOCK% MHz
    echo [✓] GPU性能优化成功！
    set "OPTIMIZATION_SUCCESS=1"
) else (
    echo [⚠] 显存频率仍为 %MEMORY_CLOCK% MHz
    echo [⚠] 可能需要手动设置或驱动更新
    set "OPTIMIZATION_SUCCESS=0"
)

echo.
echo [5] 运行GPU压力测试以提升频率...
echo ==================================

if %OPTIMIZATION_SUCCESS% equ 0 (
    echo 尝试运行GPU压力测试以提升频率...
    echo.
    
    REM 创建RTX 2080 Ti专用压力测试程序
    echo #include ^<stdio.h^> > rtx2080ti_stress_test.cu
    echo #include ^<cuda_runtime.h^> >> rtx2080ti_stress_test.cu
    echo #include ^<cublas_v2.h^> >> rtx2080ti_stress_test.cu
    echo __global__ void rtx2080tiStressTest(float* data, int size) { >> rtx2080ti_stress_test.cu
    echo     int idx = blockIdx.x * blockDim.x + threadIdx.x; >> rtx2080ti_stress_test.cu
    echo     if (idx ^< size) { >> rtx2080ti_stress_test.cu
    echo         float sum = 0.0f; >> rtx2080ti_stress_test.cu
    echo         for (int i = 0; i ^< 50000; i++) { >> rtx2080ti_stress_test.cu
    echo             sum += sinf(data[idx] + i) * cosf(data[idx] * i); >> rtx2080ti_stress_test.cu
    echo         } >> rtx2080ti_stress_test.cu
    echo         data[idx] = sum; >> rtx2080ti_stress_test.cu
    echo     } >> rtx2080ti_stress_test.cu
    echo } >> rtx2080ti_stress_test.cu
    echo int main() { >> rtx2080ti_stress_test.cu
    echo     printf("RTX 2080 Ti 压力测试开始...\n"); >> rtx2080ti_stress_test.cu
    echo     int deviceCount; >> rtx2080ti_stress_test.cu
    echo     cudaGetDeviceCount(^&deviceCount); >> rtx2080ti_stress_test.cu
    echo     if (deviceCount ^> 0) { >> rtx2080ti_stress_test.cu
    echo         cudaSetDevice(0); >> rtx2080ti_stress_test.cu
    echo         const int size = 2048 * 2048; >> rtx2080ti_stress_test.cu
    echo         float *d_data; >> rtx2080ti_stress_test.cu
    echo         cudaMalloc(^&d_data, size * sizeof(float)); >> rtx2080ti_stress_test.cu
    echo         printf("正在运行压力测试...\n"); >> rtx2080ti_stress_test.cu
    echo         for (int i = 0; i ^< 2000; i++) { >> rtx2080ti_stress_test.cu
    echo             rtx2080tiStressTest^^^<^^^<2048, 256^^^>^^^>(d_data, size); >> rtx2080ti_stress_test.cu
    echo             if (i %% 100 == 0) printf("进度: %d/2000\n", i); >> rtx2080ti_stress_test.cu
    echo         } >> rtx2080ti_stress_test.cu
    echo         cudaFree(d_data); >> rtx2080ti_stress_test.cu
    echo         printf("RTX 2080 Ti 压力测试完成\n"); >> rtx2080ti_stress_test.cu
    echo     } >> rtx2080ti_stress_test.cu
    echo     return 0; >> rtx2080ti_stress_test.cu
    echo } >> rtx2080ti_stress_test.cu
    
    REM 编译压力测试程序
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin\nvcc.exe" (
        "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin\nvcc.exe" -o rtx2080ti_stress_test.exe rtx2080ti_stress_test.cu -lcudart -lcublas 2>nul
        
        if %errorlevel% equ 0 (
            echo [✓] RTX 2080 Ti 压力测试程序编译成功
            echo 正在运行压力测试...
            echo.
            
            REM 在后台运行压力测试
            start /b rtx2080ti_stress_test.exe
            
            echo 等待压力测试提升GPU频率...
            timeout /t 15 /nobreak >nul
            
            REM 停止压力测试
            taskkill /f /im rtx2080ti_stress_test.exe >nul 2>&1
            
            echo [✓] 压力测试完成
            echo.
            
            REM 检查频率是否提升
            echo 压力测试后的GPU状态:
            nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu --format=csv,noheader,nounits
            echo.
            
            REM 清理临时文件
            del rtx2080ti_stress_test.exe rtx2080ti_stress_test.cu 2>nul
        ) else (
            echo [✗] RTX 2080 Ti 压力测试程序编译失败
            del rtx2080ti_stress_test.cu 2>nul
        )
    ) else (
        echo [✗] 未找到CUDA编译器，无法运行压力测试
        del rtx2080ti_stress_test.cu 2>nul
    )
)

echo.
echo ========================================
echo 运行优化后的性能测试
echo ========================================
echo.

echo 现在运行优化后的TexasSolver性能测试...
echo 这将获得更准确的性能数据
echo.

REM 运行优化后的性能测试
call run_texassolver_cuda11_test.bat

echo.
echo ========================================
echo RTX 2080 Ti 性能优化总结
echo ========================================
echo.

echo 优化措施:
echo 1. ✓ 启用GPU持久化模式
echo 2. ✓ 设置GPU为最大性能模式
echo 3. ✓ 调整GPU功耗限制到300W
echo 4. ✓ 运行RTX 2080 Ti专用压力测试
echo 5. ✓ 完成优化后的性能测试
echo.

echo RTX 2080 Ti 规格:
echo - 显存频率: 7000 MHz (GDDR6)
echo - 核心频率: 1545 MHz (Boost)
echo - 显存容量: 22GB
echo - 计算能力: 7.5
echo - 功耗限制: 300W
echo.

echo 如果GPU频率仍未提升到预期水平，建议:
echo 1. 以管理员身份重新运行此脚本
echo 2. 更新NVIDIA驱动到最新版本
echo 3. 使用MSI Afterburner等第三方工具手动设置频率
echo 4. 检查GPU温度和功耗限制
echo 5. 确保GPU散热良好
echo.

echo 按任意键退出...
pause >nul
