@echo off
echo Testing file paths for TexasSolver...

echo.
echo Current directory: %CD%

echo.
echo Checking release directory structure:
if exist "release\resources\compairer\card5_dic_sorted.txt" (
    echo ✓ card5_dic_sorted.txt exists
) else (
    echo ✗ card5_dic_sorted.txt NOT found
)

if exist "release\resources\compairer\card5_dic_sorted_shortdeck.txt" (
    echo ✓ card5_dic_sorted_shortdeck.txt exists
) else (
    echo ✗ card5_dic_sorted_shortdeck.txt NOT found
)

if exist "release\resources\compairer\card5_dic_zipped.bin" (
    echo ✓ card5_dic_zipped.bin exists
) else (
    echo ✗ card5_dic_zipped.bin NOT found
)

if exist "release\resources\compairer\card5_dic_zipped_shortdeck.bin" (
    echo ✓ card5_dic_zipped_shortdeck.bin exists
) else (
    echo ✗ card5_dic_zipped_shortdeck.bin NOT found
)

echo.
echo Checking parameters directory:
if exist "release\parameters" (
    echo ✓ parameters directory exists
    dir "release\parameters" /B
) else (
    echo ✗ parameters directory NOT found
)

echo.
echo File sizes in release/resources/compairer/:
if exist "release\resources\compairer" (
    dir "release\resources\compairer" /Q
) else (
    echo Directory not found
)

echo.
echo Testing with relative paths from release directory:
cd release
echo Current directory: %CD%
if exist "resources\compairer\card5_dic_sorted.txt" (
    echo ✓ resources\compairer\card5_dic_sorted.txt accessible
) else (
    echo ✗ resources\compairer\card5_dic_sorted.txt NOT accessible
)
cd ..

pause
