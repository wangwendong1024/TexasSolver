@echo off
echo Testing Qt paths and files...

set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64

echo.
echo Checking Qt installation directory:
if exist "%QTDIR%" (
    echo ✓ Qt directory exists: %QTDIR%
) else (
    echo ✗ Qt directory NOT found: %QTDIR%
    exit /b 1
)

echo.
echo Checking Qt DLL files:
if exist "%QTDIR%\bin\Qt5Core.dll" (
    echo ✓ Qt5Core.dll found
) else (
    echo ✗ Qt5Core.dll NOT found
)

if exist "%QTDIR%\bin\Qt5Gui.dll" (
    echo ✓ Qt5Gui.dll found
) else (
    echo ✗ Qt5Gui.dll NOT found
)

if exist "%QTDIR%\bin\Qt5Widgets.dll" (
    echo ✓ Qt5Widgets.dll found
) else (
    echo ✗ Qt5Widgets.dll NOT found
)

if exist "%QTDIR%\bin\Qt5WinExtras.dll" (
    echo ✓ Qt5WinExtras.dll found
) else (
    echo ✗ Qt5WinExtras.dll NOT found
)

if exist "%QTDIR%\bin\Qt5Svg.dll" (
    echo ✓ Qt5Svg.dll found
) else (
    echo ✗ Qt5Svg.dll NOT found
)

echo.
echo Checking Qt tools:
if exist "%QTDIR%\bin\moc.exe" (
    echo ✓ moc.exe found
) else (
    echo ✗ moc.exe NOT found
)

if exist "%QTDIR%\bin\uic.exe" (
    echo ✓ uic.exe found
) else (
    echo ✗ uic.exe NOT found
)

echo.
echo Checking plugins directory:
if exist "%QTDIR%\plugins" (
    echo ✓ plugins directory found
) else (
    echo ✗ plugins directory NOT found
)

echo.
echo All Qt paths and files verified!
pause
