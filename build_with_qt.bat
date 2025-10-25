@echo off
echo Building TexasSolver with Qt integration...

REM Set Qt environment
set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set PATH=%QTDIR%\bin;%PATH%
set QT_PLUGIN_PATH=%QTDIR%\plugins
set QT_QPA_PLATFORM_PLUGIN_PATH=%QTDIR%\plugins\platforms

echo Qt environment set:
echo QTDIR=%QTDIR%
echo.

REM Clean previous build
echo Cleaning previous build...
if exist debug rmdir /s /q debug
if exist release rmdir /s /q release

REM Create debug directory
if not exist debug mkdir debug

REM Generate MOC files
echo Generating MOC files...
"%QTDIR%\bin\moc.exe" include\runtime\qsolverjob.h -o debug\moc_qsolverjob.cpp
"%QTDIR%\bin\moc.exe" include\ui\treemodel.h -o debug\moc_treemodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\worditemdelegate.h -o debug\moc_worditemdelegate.cpp
"%QTDIR%\bin\moc.exe" include\ui\tablestrategymodel.h -o debug\moc_tablestrategymodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\strategyitemdelegate.h -o debug\moc_strategyitemdelegate.cpp
"%QTDIR%\bin\moc.exe" include\ui\detailviewermodel.h -o debug\moc_detailviewermodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\detailitemdelegate.h -o debug\moc_detailitemdelegate.cpp
"%QTDIR%\bin\moc.exe" include\ui\roughstrategyviewermodel.h -o debug\moc_roughstrategyviewermodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\roughstrategyitemdelegate.h -o debug\moc_roughstrategyitemdelegate.cpp
"%QTDIR%\bin\moc.exe" include\ui\droptextedit.h -o debug\moc_droptextedit.cpp
"%QTDIR%\bin\moc.exe" include\ui\htmltablerangeview.h -o debug\moc_htmltablerangeview.cpp
"%QTDIR%\bin\moc.exe" include\ui\rangeselectortablemodel.h -o debug\moc_rangeselectortablemodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\rangeselectortabledelegate.h -o debug\moc_rangeselectortabledelegate.cpp
"%QTDIR%\bin\moc.exe" include\ui\boardselectortablemodel.h -o debug\moc_boardselectortablemodel.cpp
"%QTDIR%\bin\moc.exe" include\ui\boardselectortabledelegate.h -o debug\moc_boardselectortabledelegate.cpp
"%QTDIR%\bin\moc.exe" mainwindow.h -o debug\moc_mainwindow.cpp
"%QTDIR%\bin\moc.exe" qstextedit.h -o debug\moc_qstextedit.cpp
"%QTDIR%\bin\moc.exe" strategyexplorer.h -o debug\moc_strategyexplorer.cpp
"%QTDIR%\bin\moc.exe" qstreeview.h -o debug\moc_qstreeview.cpp
"%QTDIR%\bin\moc.exe" htmltableview.h -o debug\moc_htmltableview.cpp
"%QTDIR%\bin\moc.exe" rangeselector.h -o debug\moc_rangeselector.cpp
"%QTDIR%\bin\moc.exe" boardselector.h -o debug\moc_boardselector.cpp
"%QTDIR%\bin\moc.exe" settingeditor.h -o debug\moc_settingeditor.cpp

REM Generate UIC files
echo Generating UIC files...
"%QTDIR%\bin\uic.exe" mainwindow.ui -o debug\ui_mainwindow.h
"%QTDIR%\bin\uic.exe" strategyexplorer.ui -o debug\ui_strategyexplorer.h
"%QTDIR%\bin\uic.exe" rangeselector.ui -o debug\ui_rangeselector.h
"%QTDIR%\bin\uic.exe" boardselector.ui -o debug\ui_boardselector.h
"%QTDIR%\bin\uic.exe" settingeditor.ui -o debug\ui_settingeditor.h

echo.
echo MOC and UIC files generated successfully!
echo You can now build the project in Visual Studio.
echo.
pause
