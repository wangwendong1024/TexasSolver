@echo off
echo Testing resource file paths...

echo.
echo Current directory:
cd

echo.
echo Checking for resources directory:
if exist "resources" (
    echo ✓ resources directory found in current directory
) else (
    echo ✗ resources directory NOT found in current directory
)

echo.
echo Checking for compairer files:
if exist "resources\compairer" (
    echo ✓ resources\compairer directory found
) else (
    echo ✗ resources\compairer directory NOT found
)

if exist "resources\compairer\card5_dic_sorted.txt" (
    echo ✓ card5_dic_sorted.txt found
) else (
    echo ✗ card5_dic_sorted.txt NOT found
)

if exist "resources\compairer\card5_dic_zipped.bin" (
    echo ✓ card5_dic_zipped.bin found
) else (
    echo ✗ card5_dic_zipped.bin NOT found
)

if exist "resources\compairer\card5_dic_sorted_shortdeck.txt" (
    echo ✓ card5_dic_sorted_shortdeck.txt found
) else (
    echo ✗ card5_dic_sorted_shortdeck.txt NOT found
)

if exist "resources\compairer\card5_dic_zipped_shortdeck.bin" (
    echo ✓ card5_dic_zipped_shortdeck.bin found
) else (
    echo ✗ card5_dic_zipped_shortdeck.bin NOT found
)

echo.
echo Checking debug directory:
if exist "debug" (
    echo ✓ debug directory found
    if exist "debug\resources" (
        echo ✓ debug\resources directory found
    ) else (
        echo ✗ debug\resources directory NOT found
    )
) else (
    echo ✗ debug directory NOT found
)

echo.
pause
