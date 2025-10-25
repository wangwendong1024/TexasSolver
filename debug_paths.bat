@echo off
echo Debugging file paths...

echo.
echo Current working directory:
cd

echo.
echo Checking if we're in the right directory:
if exist "TexasSolverGui.vcxproj" (
    echo ✓ Found TexasSolverGui.vcxproj - we're in the project root
) else (
    echo ✗ TexasSolverGui.vcxproj not found - wrong directory
)

echo.
echo Checking resources directory:
if exist "resources" (
    echo ✓ resources directory exists
    if exist "resources\compairer" (
        echo ✓ resources\compairer directory exists
        if exist "resources\compairer\card5_dic_zipped.bin" (
            echo ✓ card5_dic_zipped.bin exists
        ) else (
            echo ✗ card5_dic_zipped.bin NOT found
        )
    ) else (
        echo ✗ resources\compairer directory NOT found
    )
) else (
    echo ✗ resources directory NOT found
)

echo.
echo Checking debug directory:
if exist "debug" (
    echo ✓ debug directory exists
    if exist "debug\resources" (
        echo ✓ debug\resources directory exists
    ) else (
        echo ✗ debug\resources directory NOT found
    )
) else (
    echo ✗ debug directory NOT found
)

echo.
echo Testing file paths that the program might use:
echo Testing: .\resources\compairer\card5_dic_zipped.bin
if exist ".\resources\compairer\card5_dic_zipped.bin" (
    echo ✓ Found with .\ prefix
) else (
    echo ✗ NOT found with .\ prefix
)

echo Testing: resources\compairer\card5_dic_zipped.bin
if exist "resources\compairer\card5_dic_zipped.bin" (
    echo ✓ Found without .\ prefix
) else (
    echo ✗ NOT found without .\ prefix
)

echo.
pause
