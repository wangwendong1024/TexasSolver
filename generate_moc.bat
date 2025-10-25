@echo off
echo Generating Qt MOC files...

set QTDIR=E:\qt\pc\qt_5.15\5.15.0\msvc2019_64
set MOC=%QTDIR%\bin\moc.exe

if not exist "%MOC%" (
    echo Error: Qt MOC not found at %MOC%
    pause
    exit /b 1
)

echo Creating debug directory...
if not exist debug mkdir debug

echo Generating MOC files...

REM Generate MOC files for all Qt classes
"%MOC%" include\runtime\qsolverjob.h -o debug\moc_qsolverjob.cpp
"%MOC%" include\ui\treemodel.h -o debug\moc_treemodel.cpp
"%MOC%" include\ui\worditemdelegate.h -o debug\moc_worditemdelegate.cpp
"%MOC%" include\ui\tablestrategymodel.h -o debug\moc_tablestrategymodel.cpp
"%MOC%" include\ui\strategyitemdelegate.h -o debug\moc_strategyitemdelegate.cpp
"%MOC%" include\ui\detailviewermodel.h -o debug\moc_detailviewermodel.cpp
"%MOC%" include\ui\detailitemdelegate.h -o debug\moc_detailitemdelegate.cpp
"%MOC%" include\ui\roughstrategyviewermodel.h -o debug\moc_roughstrategyviewermodel.cpp
"%MOC%" include\ui\roughstrategyitemdelegate.h -o debug\moc_roughstrategyitemdelegate.cpp
"%MOC%" include\ui\droptextedit.h -o debug\moc_droptextedit.cpp
"%MOC%" include\ui\htmltablerangeview.h -o debug\moc_htmltablerangeview.cpp
"%MOC%" include\ui\rangeselectortablemodel.h -o debug\moc_rangeselectortablemodel.cpp
"%MOC%" include\ui\rangeselectortabledelegate.h -o debug\moc_rangeselectortabledelegate.cpp
"%MOC%" include\ui\boardselectortablemodel.h -o debug\moc_boardselectortablemodel.cpp
"%MOC%" include\ui\boardselectortabledelegate.h -o debug\moc_boardselectortabledelegate.cpp
"%MOC%" mainwindow.h -o debug\moc_mainwindow.cpp
"%MOC%" qstextedit.h -o debug\moc_qstextedit.cpp
"%MOC%" strategyexplorer.h -o debug\moc_strategyexplorer.cpp
"%MOC%" qstreeview.h -o debug\moc_qstreeview.cpp
"%MOC%" htmltableview.h -o debug\moc_htmltableview.cpp
"%MOC%" rangeselector.h -o debug\moc_rangeselector.cpp
"%MOC%" boardselector.h -o debug\moc_boardselector.cpp
"%MOC%" settingeditor.h -o debug\moc_settingeditor.cpp

echo MOC files generated successfully!
echo Now you can build the project in Visual Studio.
pause
