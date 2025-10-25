@echo off
echo Copying resources to output directory...

REM 创建目标目录
if not exist "debug\resources\compairer" mkdir "debug\resources\compairer"
if not exist "release\resources\compairer" mkdir "release\resources\compairer"

REM 复制文件到debug目录
if exist "resources\compairer\*.*" (
    copy /y "resources\compairer\*.*" "debug\resources\compairer\"
    echo Resources copied to debug directory
) else (
    echo Warning: resources\compairer directory not found
)

REM 复制文件到release目录
if exist "resources\compairer\*.*" (
    copy /y "resources\compairer\*.*" "release\resources\compairer\"
    echo Resources copied to release directory
) else (
    echo Warning: resources\compairer directory not found
)

echo Resource copy completed.
pause
