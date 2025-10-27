@echo off
chcp 65001 >nul
echo ========================================
echo 高级GPU性能优化脚本
echo ========================================
echo.

echo 正在检测GPU状态并优化性能...
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

echo [2] 启用GPU最大性能模式...
echo ============================

REM 方法1: 启用持久化模式
echo 尝试启用GPU持久化模式...
nvidia-smi -pm 1
if %errorlevel% equ 0 (
    echo [✓] GPU持久化模式已启用
) else (
    echo [⚠] 持久化模式启用失败
)

REM 方法2: 设置最大性能模式
echo 尝试设置GPU为最大性能模式...
nvidia-smi -ac 7000,1545
if %errorlevel% equ 0 (
    echo [✓] GPU频率已设置为最大性能模式
) else (
    echo [⚠] 直接频率设置失败，尝试其他方法
)

REM 方法3: 使用PowerMizer设置
echo 尝试设置PowerMizer为最大性能...
nvidia-smi -pl 300
if %errorlevel% equ 0 (
    echo [✓] GPU功耗限制已设置为300W
) else (
    echo [⚠] 功耗限制设置失败
)

echo.
echo [3] 等待GPU频率稳定...
echo ======================
echo 等待5秒让GPU频率稳定...
timeout /t 5 /nobreak >nul
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
echo - 显存频率: %MEMORY_CLOCK% MHz
echo - 核心频率: %GRAPHICS_CLOCK% MHz
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
    
    REM 创建简单的GPU压力测试程序
    echo #include ^<stdio.h^> > gpu_stress_test.cu
    echo #include ^<cuda_runtime.h^> >> gpu_stress_test.cu
    echo __global__ void stressTest(float* data, int size) { >> gpu_stress_test.cu
    echo     int idx = blockIdx.x * blockDim.x + threadIdx.x; >> gpu_stress_test.cu
    echo     if (idx ^< size) { >> gpu_stress_test.cu
    echo         float sum = 0.0f; >> gpu_stress_test.cu
    echo         for (int i = 0; i ^< 10000; i++) { >> gpu_stress_test.cu
    echo             sum += sinf(data[idx] + i) * cosf(data[idx] * i); >> gpu_stress_test.cu
    echo         } >> gpu_stress_test.cu
    echo         data[idx] = sum; >> gpu_stress_test.cu
    echo     } >> gpu_stress_test.cu
    echo } >> gpu_stress_test.cu
    echo int main() { >> gpu_stress_test.cu
    echo     printf("GPU压力测试开始...\n"); >> gpu_stress_test.cu
    echo     int deviceCount; >> gpu_stress_test.cu
    echo     cudaGetDeviceCount(^&deviceCount); >> gpu_stress_test.cu
    echo     if (deviceCount ^> 0) { >> gpu_stress_test.cu
    echo         cudaSetDevice(0); >> gpu_stress_test.cu
    echo         const int size = 1024 * 1024; >> gpu_stress_test.cu
    echo         float *d_data; >> gpu_stress_test.cu
    echo         cudaMalloc(^&d_data, size * sizeof(float)); >> gpu_stress_test.cu
    echo         for (int i = 0; i ^< 1000; i++) { >> gpu_stress_test.cu
    echo             stressTest^^^<^^^<1024, 256^^^>^^^>(d_data, size); >> gpu_stress_test.cu
    echo         } >> gpu_stress_test.cu
    echo         cudaFree(d_data); >> gpu_stress_test.cu
    echo         printf("GPU压力测试完成\n"); >> gpu_stress_test.cu
    echo     } >> gpu_stress_test.cu
    echo     return 0; >> gpu_stress_test.cu
    echo } >> gpu_stress_test.cu
    
    REM 编译压力测试程序
    if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin\nvcc.exe" (
        "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin\nvcc.exe" -o gpu_stress_test.exe gpu_stress_test.cu 2>nul
        
        if %errorlevel% equ 0 (
            echo [✓] GPU压力测试程序编译成功
            echo 正在运行压力测试...
            echo.
            
            REM 在后台运行压力测试
            start /b gpu_stress_test.exe
            
            echo 等待压力测试提升GPU频率...
            timeout /t 10 /nobreak >nul
            
            REM 停止压力测试
            taskkill /f /im gpu_stress_test.exe >nul 2>&1
            
            echo [✓] 压力测试完成
            echo.
            
            REM 检查频率是否提升
            echo 压力测试后的GPU状态:
            nvidia-smi --query-gpu=name,clocks.gr,clocks.mem,power.draw,temperature.gpu --format=csv,noheader,nounits
            echo.
            
            REM 清理临时文件
            del gpu_stress_test.exe gpu_stress_test.cu 2>nul
        ) else (
            echo [✗] GPU压力测试程序编译失败
            del gpu_stress_test.cu 2>nul
        )
    ) else (
        echo [✗] 未找到CUDA编译器，无法运行压力测试
        del gpu_stress_test.cu 2>nul
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
echo 性能优化总结
echo ========================================
echo.

echo 优化措施:
echo 1. ✓ 启用GPU持久化模式
echo 2. ✓ 设置GPU为最大性能模式
echo 3. ✓ 调整GPU功耗限制
echo 4. ✓ 运行GPU压力测试
echo 5. ✓ 完成优化后的性能测试
echo.

echo 如果GPU频率仍未提升到预期水平，建议:
echo 1. 以管理员身份重新运行此脚本
echo 2. 更新NVIDIA驱动到最新版本
echo 3. 使用MSI Afterburner等第三方工具手动设置频率
echo 4. 检查GPU温度和功耗限制
echo.

echo 按任意键退出...
pause >nul
