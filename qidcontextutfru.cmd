::@set myfiles=d:\Quest2\adb
@echo off
::@chcp 65001
@set myfiles=C:\Temp\SendToHeadset
@set sendtofoldercmdfolder=C:\Temp\SendToHeadset

@setlocal enableextensions enabledelayedexpansion

call :_checkdevice

set hidefrstp=1^>NUL
set hidescndp=2^>NUL

set installname=%1

For %%v In (!installname!) Do ( 
Set "PathIncludePathGame=%%~dpv"
@set extens=%%~xv
@set attribs=%%~av
@set extname=%%~nxv
if /i !extens!==.apk goto _SingleApkInstall
if !attribs! GEQ d-------- goto _MultiApkInstall
if /i !extname!==install.txt call :_InstallCmdCreate
)
@echo ================================================
@echo.
rem StartRusTextBlock
@echo      +++ Установка завершена +++
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo +++ Installation is complete +++
rem EndEngTextBlock
@echo.
goto :_exittimeout

:_errorfile
@echo.
@echo.
@echo ===============================================================
rem StartRusTextBlock
@echo       +++ Это не каталог, не apk файл и не install.txt +++
@echo.
@echo                   Установить не получится
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo +++ This is not a directory, not an apk file, and not an install.txt +++
rem @echo.
rem @echo                   Installation will not be possible
rem EndEngTextBlock
@echo --------------------------------------------------------------
@echo.
goto :_exitout

:_MultiApkInstall
@cls
@echo.
set "gPath=%installname%"
set /a MultiCounterOk=0
set /a MultiCounterEr=0
for /r %gPath% %%a in (*.apk) do (
set "apkname=%%a"
@set "apknamefile=%%~nxa"
@set PathBeforeObbPath=%%~dpa
@set "apkname=%%a"
@For /f "tokens=*" %%v In ("!apkname!") Do Set "PathGame=%%~dpv"
@for /f "tokens=*" %%d in ('@%myfiles%\aapt2 dump packagename "!apkname!"') do set pkgname=%%d
@if not defined pkgname call :_MultiInstallApkErr
@FOR /F "tokens=2 delims='" %%g IN ('@%MYFILES%\aapt2 dump badging "!apkname!" ^| find "application-label:"') DO set applabel=%%g
call :_MultiInstallProcess
@echo -----------------------------------------------
)
@echo ================================================
@echo.
rem StartRusTextBlock
@echo  +++ Установка завершена +++
@echo.
@echo   Установлено		: !MultiCounterOk!
@echo   Не установлено	: %MultiCounterEr%
@echo --------------------------------------------
@echo.
@echo   Список не установленных приложений сохранен в %sendtofoldercmdfolder%\notinstalled.txt
@echo   Попробуйте установить их вручную. Также возможно, что в имени файла или каталога
@echo   есть восклицательный знак - в этом случае попробуйте удалить его.
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo +++ Installation completed +++
rem @echo.
rem @echo   Installed		: !MultiCounterOk!
rem @echo   Not installed	: %MultiCounterEr%
rem @echo --------------------------------------------
rem @echo.
rem @echo   The list of not installed applications is saved in %sendtofoldercmdfolder%\notinstalled.txt
rem @echo   Try installing them manually. Also, it's possible that there is an exclamation mark 
rem @echo   in the file name or directory - if so, try removing it.
rem EndEngTextBlock
@echo.
goto :_exittimeout

:_MultiInstallProcess
set hidefrstp=1^>NUL
set hidescndp=2^>NUL
if not defined applabel exit /b
set /a MultiCounterOk=%MultiCounterOk%+1
rem StartRusTextBlock
@echo  %MultiCounterOk%. Устанавливаем  "%applabel%"
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo %MultiCounterOk%. Installing "%applabel%"
rem EndEngTextBlock
@%MYFILES%\ADB install -r -g --no-streaming "%apkname%" %hidefrstp% %hidescndp%
@IF !ERRORLEVEL!==0 (call :_MultiCopyObbInslallApk) else (call :_MultiInstallApkErr)
set applabel=
set pkgname=
exit /b

:_MultiCopyObbInslallApk
if not exist "%PathGame%%pkgname%" call :_MultiInstalledOk && exit /b
@echo --
rem StartRusTextBlock
@echo = Копируем "%pkgname%" в каталог OBB на шлем..
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Copying "%pkgname%" to the OBB directory on the headset..
rem EndEngTextBlock
@%MYFILES%\ADB shell mkdir -p /sdcard/Android/obb/%pkgname% %hidefrstp% %hidescndp%
@%MYFILES%\ADB push "%PathBeforeObbPath%%pkgname%" /sdcard/Android/obb/ %hidefrstp% %hidescndp%
call :_MultiInstalledOk
exit /b

:_MultiInstallApkErr
@echo.
@echo.
rem StartRusTextBlock
@echo  +++ Ошибка установки !apknamefile! +++
@echo.
@echo  == Продолжаем установку
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo  +++ Installation error !apknamefile! +++
rem @echo.
rem @echo  == Continuing installation
rem EndEngTextBlock
@echo.
@echo.
set /a MultiCounterEr=%MultiCounterEr%+1
@echo  !apkname! >>%sendtofoldercmdfolder%\notinstalled.txt
exit /b

:_MultiInstalledOk
@echo --
rem StartRusTextBlock
@echo = Установлено успешно
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Successfully installed
rem EndEngTextBlock
exit /b

:_SingleApkInstall
set hidefrstp=1^>NUL
set hidescndp=2^>NUL
@echo off
@cls
@echo.
@SET pkgName=
@set apkname=
set enterapkname=
@Set "apkname=%installname%"
@For %%v In (!apkname!) Do Set "PathIncludePathGame=%%~dpv"
for /f "tokens=*" %%a in ('%myfiles%\aapt2 dump packagename !apkname!') do set pkgname=%%a
FOR /F "tokens=2 delims='" %%g IN ('@%MYFILES%\aapt2 dump badging !apkname! ^| find "application-label:"') DO set applabel=%%g
@echo -----------------------------------------------
rem StartRusTextBlock
@echo = Устанавливаем "%applabel%"
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Installing "%applabel%"
rem EndEngTextBlock
%MYFILES%\ADB install -r -g %down% --no-streaming !apkname! %hidefrstp% %hidescndp%
@IF !ERRORLEVEL!==0 (call :_SingleCopyObbInslallApk) else (call :_SingleErrInstallApk)
@echo --
rem StartRusTextBlock
@echo = Установлено успешно
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Successfully installed
rem EndEngTextBlock
@echo ===========================================
echo.
goto :_exittimeout

:_SingleCopyObbInslallApk
if not exist "%PathIncludePathGame%%pkgname%" exit /b
@echo --
rem StartRusTextBlock
@echo   Копируем "%pkgname%" в каталог OBB в шлем...
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Copying "%pkgname%" to the OBB directory on the headset..
rem EndEngTextBlock
@%MYFILES%\ADB shell mkdir -p /sdcard/Android/obb/%pkgname% %hidefrstp% %hidescndp%
@%MYFILES%\ADB push "%PathIncludePathGame%%pkgname%" /sdcard/Android/obb/ %hidefrstp% %hidescndp%
exit /b

:_SingleErrInstallApk
@echo ===========================================
rem StartRusTextBlock
@echo 	    +++ Ошибка установки +++
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo +++ Installation Error +++
rem EndEngTextBlock
echo.
@goto _exitout

:_InstallCmdCreate
@echo  ===========================================
rem StartRusTextBlock
@echo  = Установка по сценарию install.txt
@echo.
@echo    Если во время установки возникнут ошибки,
@echo    они будут записаны в файл errors.txt в каталоге с игрой.
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo = Installation via install.txt script
rem @echo.
rem @echo    If errors occur during installation,
rem @echo    they will be recorded in the errors.txt file in the game directory.
rem EndEngTextBlock
@echo  -----
@echo @echo off>>"%PathIncludePathGame%install.cmd
@echo @echo.>>"%PathIncludePathGame%install.cmd"
@echo cd ^/D "%PathIncludePathGame%">>"%PathIncludePathGame%install.cmd"
@for /f "UseBackQ delims=" %%a in (%installname%) do (
@set newstring=%%a
@echo %myfiles%\!newstring! 2^>^>errors.txt>>"%PathIncludePathGame%install.cmd"
@echo @echo  ^----->>"%PathIncludePathGame%install.cmd"
@echo @echo.>>"%PathIncludePathGame%install.cmd"
)
@cmd /c "%PathIncludePathGame%install.cmd"
@del "%PathIncludePathGame%install.cmd" /q
@findstr "^" "%PathIncludePathGame%errors.txt">nul&& echo.|| @del "%PathIncludePathGame%errors.txt" /q
exit /b

:_exittimeout
@echo.
rem StartRusTextBlock
@echo ^>^>^> Нажмите любую кнопку для выхода из программы ^<^<^<
@echo               или подождите пять секунд
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo ^>^>^> Press any key to exit the program ^<^<^< 
rem @echo           or wait five seconds
rem EndEngTextBlock
@timeout 5 >nul
::@pause >nul
@exit


:_exitout
@echo.
rem StartRusTextBlock
@echo ^>^>^> Нажмите любую кнопку для выхода из программы ^<^<^<
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo ^>^>^> Press any key to exit the program ^<^<^<
rem EndEngTextBlock
@pause >nul
@exit

rem :_DeleteWrongSymbols
rem @for /r %%a in (*.zip) do (
rem set name=%%~nxa
rem call set "name=%%name:(=%%"
rem call set "name=%%name:)=%%"
rem rem call set "name=%%name:!=%%"
rem call set "name=%%name:+=%%"
rem call set "name=%%name: =%%"
rem call set "name=%%name:&=%%"
rem  cmd/v/c ren "%%a" "!name:%%=!"
rem )
rem set installname=%name%
rem set installname=%1
rem exit/b

:_checkdevice
@echo.
rem StartRusTextBlock
@echo ADB запускается....
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo ADB is starting..
rem EndEngTextBlock
@adb devices 1>nul 2>nul
@FOR /F "skip=1 tokens=2" %%G IN ('%sendtofoldercmdfolder%\adb devices ^| find "device"') DO set adbdevices=%%G
@if [%adbdevices%]==[] goto _NF
@cls
exit /b
:_NF
@cls
@echo.
@echo.
@echo.
rem StartRusTextBlock
@echo     +++++ Шлем не найден +++++
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo     +++++ Headset not found +++++
rem EndEngTextBlock
@echo.
@echo.
@echo.
rem StartRusTextBlock
@echo  Проверьте кабельное соединение и правильность установки драйверов.
@echo  Затем перезапустите эту программу снова.
rem EndRusTextBlock
rem StartEngTextBlock
rem @echo  Check the cable connection and the correctness of the driver installation.
rem @echo  Then restart this program again.
rem EndEngTextBlock
@echo.
@goto _exitout

