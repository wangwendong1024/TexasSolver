@echo off
REM 后编译脚本 - 复制resources文件夹到输出目录

set "PROJECT_DIR=%~dp0"
set "OUTPUT_DIR=%1"

if "%OUTPUT_DIR%"=="" (
    echo Error: Output directory not specified
    exit /b 1
)

echo Project directory: %PROJECT_DIR%
echo Output directory: %OUTPUT_DIR%

REM 创建resources目录结构
if not exist "%OUTPUT_DIR%\resources" mkdir "%OUTPUT_DIR%\resources"
if not exist "%OUTPUT_DIR%\resources\compairer" mkdir "%OUTPUT_DIR%\resources\compairer"

REM 复制compairer文件
if exist "%PROJECT_DIR%resources\compairer\card5_dic_sorted.txt" (
    copy /y "%PROJECT_DIR%resources\compairer\card5_dic_sorted.txt" "%OUTPUT_DIR%\resources\compairer\"
    echo Copied card5_dic_sorted.txt
) else (
    echo Warning: card5_dic_sorted.txt not found
)

if exist "%PROJECT_DIR%resources\compairer\card5_dic_sorted_shortdeck.txt" (
    copy /y "%PROJECT_DIR%resources\compairer\card5_dic_sorted_shortdeck.txt" "%OUTPUT_DIR%\resources\compairer\"
    echo Copied card5_dic_sorted_shortdeck.txt
) else (
    echo Warning: card5_dic_sorted_shortdeck.txt not found
)

if exist "%PROJECT_DIR%resources\compairer\card5_dic_zipped.bin" (
    copy /y "%PROJECT_DIR%resources\compairer\card5_dic_zipped.bin" "%OUTPUT_DIR%\resources\compairer\"
    echo Copied card5_dic_zipped.bin
) else (
    echo Warning: card5_dic_zipped.bin not found
)

if exist "%PROJECT_DIR%resources\compairer\card5_dic_zipped_shortdeck.bin" (
    copy /y "%PROJECT_DIR%resources\compairer\card5_dic_zipped_shortdeck.bin" "%OUTPUT_DIR%\resources\compairer\"
    echo Copied card5_dic_zipped_shortdeck.bin
) else (
    echo Warning: card5_dic_zipped_shortdeck.bin not found
)

echo Resource copy completed successfully.
