@echo off
setlocal enabledelayedexpansion

title Cai dat VoiceBot AI cho Phicomm R1

:: Set ADB path to the same folder as this bat file
set "ADB=%~dp0adb"

set RECONNECT_COUNT=0
set MAX_RECONNECT=3

goto skip_reconnect_func

:reconnect_adb
set /a RECONNECT_COUNT+=1
if !RECONNECT_COUNT! gtr %MAX_RECONNECT% (
    echo.
    echo [LOI] Da thu ket noi lai %MAX_RECONNECT% lan nhung khong thanh cong!
    pause
    goto menu
)
echo.
echo [WARN] Mat ket noi ADB, dang ket noi lai... (lan !RECONNECT_COUNT!)
"%ADB%" connect 192.168.43.1:5555
timeout /t 2 >nul
goto :eof

:skip_reconnect_func

:menu
cls
set RECONNECT_COUNT=0
echo.
echo ========================================================
echo                      CHU Y QUAN TRONG
echo ========================================================
echo.
echo   [!] KHONG DUOC RUT DIEN CUA LOA KHI DANG CAI DAT!
echo.
echo   Neu xay ra loi, phan mem se tu dong khoi phuc trang
echo   thai goc cho loa. Vui long doi cho den khi hoan tat.
echo.
echo ========================================================
echo       CAI DAT VOICEBOT AI CHO PHICOMM R1
echo ========================================================
echo.

echo [Buoc 1] Chuan bi thiet bi
echo.
echo   Vui long GIU NUT tren loa trong 10 giay de vao 
echo   che do phat WiFi (den trang phat sang nhap nhay)
echo.
echo --------------------------------------------------------
echo.
echo [Buoc 2] Ket noi WiFi tu may tinh
echo.
echo   Mo WiFi tren may tinh va tim mang: Phicomm_R1_xxx
echo   (xxx la cac ky tu bat ky)
echo   Ket noi toi mang WiFi do.
echo.
echo --------------------------------------------------------

:confirm_wifi
echo.
set /p confirm="Da ket noi toi WiFi Phicomm_R1_xxx chua? (Y/N): "
if /i "!confirm!"=="Y" goto connect_adb
if /i "!confirm!"=="N" (
    echo.
    echo Vui long thuc hien lai viec giu nut tren loa...
    goto confirm_wifi
)
echo Vui long nhap Y hoac N
goto confirm_wifi

:connect_adb
cls
echo.
echo [Buoc 3] Ket noi ADB den thiet bi
echo.
echo Dang don dep cac tien trinh ADB cu...
"%ADB%" disconnect >nul
taskkill /f /t /im adb.exe >nul 2>&1
"%ADB%" devices >nul

echo.
echo Dang ket noi den 192.168.43.1:5555...
echo.
"%ADB%" connect 192.168.43.1:5555

:: Check if device is connected (look for "device" at end of line, not "devices")
"%ADB%" devices > "%~dp0adb_devices.tmp"
type "%~dp0adb_devices.tmp"
findstr /r "5555.*device$" "%~dp0adb_devices.tmp" >nul
if errorlevel 1 (
    del "%~dp0adb_devices.tmp" 2>nul
    echo.
    echo [LOI] Khong the ket noi den thiet bi!
    echo.
    echo Vui long kiem tra:
    echo   1. May tinh da ket noi WiFi "Phicomm_R1" chua?
    echo   2. Loa da vao che do phat WiFi chua?
    echo.
    pause
    goto menu
)
del "%~dp0adb_devices.tmp" 2>nul

echo.
echo [OK] Ket noi ADB thanh cong!
echo.
timeout /t 2 >nul

:step_hide_packages
cls
echo.
echo [Buoc 4] Tat cac ung dung khong can thiet tren loa
echo.

echo Dang tat com.phicomm.speaker.player...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.player 2>&1 | findstr /ic "no devices" >nul && call :reconnect_adb && goto step_hide_packages

echo Dang tat com.phicomm.speaker.airskill...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.airskill

echo Dang tat com.phicomm.speaker.exceptionreporter...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.exceptionreporter

echo Dang tat com.phicomm.speaker.ijetty...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.ijetty

echo Dang tat com.phicomm.speaker.netctl...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.netctl

"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.systemtool
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.device

echo Dang tat com.phicomm.speaker.otaservice...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.otaservice

echo Dang tat com.phicomm.speaker.productiontest...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.productiontest

echo Dang tat com.phicomm.speaker.bugreport...
"%ADB%" shell /system/bin/pm hide com.phicomm.speaker.bugreport
echo.
echo [OK] Da tat cac ung dung khong can thiet!
echo.
timeout /t 2 >nul

:step_push_apk
cls
echo.
echo [Buoc 5] Sao chep file cai dat len thiet bi
echo.

if not exist "%~dp0app-voicebot.apk" (
    echo [LOI] Khong tim thay file app-voicebot.apk!
    echo.
    echo Vui long dat file app-voicebot.apk vao cung thu muc voi file bat nay.
    echo.
    pause
    goto menu
)

echo Dang sao chep app-voicebot.apk len thiet bi...
"%ADB%" push "%~dp0app-voicebot.apk" /data/local/tmp/app-voicebot.apk 2>&1 > "%~dp0push_result.tmp"
type "%~dp0push_result.tmp" | findstr /ic "no devices" >nul
if not errorlevel 1 (
    del "%~dp0push_result.tmp" 2>nul
    call :reconnect_adb
    goto step_push_apk
)
type "%~dp0push_result.tmp"
del "%~dp0push_result.tmp" 2>nul
echo.
echo [OK] Sao chep file thanh cong!
echo.
timeout /t 2 >nul

:step_install_apk
cls
echo.
echo [Buoc 6] Cai dat ung dung VoiceBot
echo.

set INSTALL_RETRY=0
set MAX_INSTALL_RETRY=8

:install_loop
set /a INSTALL_RETRY+=1
echo Dang cai dat... (lan !INSTALL_RETRY!/%MAX_INSTALL_RETRY%)

"%ADB%" shell /system/bin/pm install -r /data/local/tmp/app-voicebot.apk 2>&1 > "%~dp0install_result.tmp"

:: Check for no devices error
type "%~dp0install_result.tmp" | findstr /ic "no devices" >nul
if not errorlevel 1 (
    del "%~dp0install_result.tmp" 2>nul
    call :reconnect_adb
    set INSTALL_RETRY=0
    goto install_loop
)

:: Check for success
type "%~dp0install_result.tmp" | findstr /ic "Success" >nul
if not errorlevel 1 (
    type "%~dp0install_result.tmp"
    del "%~dp0install_result.tmp" 2>nul
    echo.
    echo [OK] Cai dat ung dung thanh cong!
    echo.
    goto install_success
)

:: Check for DEXOPT error - need retry
type "%~dp0install_result.tmp" | findstr /ic "INSTALL_FAILED_DEXOPT" >nul
if not errorlevel 1 (
    echo   [WARN] INSTALL_FAILED_DEXOPT - Thu lai sau 1 giay...
    del "%~dp0install_result.tmp" 2>nul
    timeout /t 1 /nobreak >nul
    
    if !INSTALL_RETRY! lss %MAX_INSTALL_RETRY% (
        goto install_loop
    ) else (
        echo.
        echo [LOI] Cai dat that bai sau %MAX_INSTALL_RETRY% lan thu!
        echo Dang khoi phuc trang thai cu cua loa...
        echo.
        goto restore_packages
    )
)

:: Other error
type "%~dp0install_result.tmp"
del "%~dp0install_result.tmp" 2>nul
echo.
echo [LOI] Cai dat that bai! Dang khoi phuc trang thai cu cua loa...
echo.
goto restore_packages

:restore_packages
echo Dang khoi phuc com.phicomm.speaker.player...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.player 2>&1 | findstr /ic "no devices" >nul && call :reconnect_adb && goto restore_packages

echo Dang khoi phuc com.phicomm.speaker.device...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.device

echo Dang khoi phuc com.phicomm.speaker.airskill...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.airskill

echo Dang khoi phuc com.phicomm.speaker.exceptionreporter...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.exceptionreporter

echo Dang khoi phuc com.phicomm.speaker.ijetty...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.ijetty

echo Dang khoi phuc com.phicomm.speaker.netctl...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.netctl

echo Dang khoi phuc com.phicomm.speaker.otaservice...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.otaservice

echo Dang khoi phuc com.phicomm.speaker.systemtool...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.systemtool

echo Dang khoi phuc com.phicomm.speaker.productiontest...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.productiontest

echo Dang khoi phuc com.phicomm.speaker.bugreport...
"%ADB%" shell /system/bin/pm unhide com.phicomm.speaker.bugreport

echo.
echo [OK] Da khoi phuc trang thai cu cua loa.
echo.
echo Vui long thu lai tu dau.
echo.
pause
goto menu

:install_success

echo Dang khoi dong ung dung...
"%ADB%" shell am start -n info.dourok.voicebot/.java.activities.MainActivity
echo.
timeout /t 2 >nul

cls
echo.
echo ========================================================
echo       CAI DAT HOAN TAT!
echo ========================================================
echo.
echo [Buoc 7] Khoi dong lai thiet bi
echo.
echo   1. RUT DIEN cua loa
echo.
echo   2. CHO 15 GIAY
echo.
echo   3. CAM LAI DIEN cho loa
echo.
echo   4. Doi loa khoi dong hoan tat (khoang 30 giay)
echo.
echo ========================================================
echo.
pause

cls
echo.
echo ========================================================
echo       CAU HINH WIFI CHO THIET BI
echo ========================================================
echo.
echo [Buoc 8] Vao che do cai dat WiFi
echo.
echo   1. GIU NUT tren loa den khi nghe thay:
echo      "Vao che do cai dat WiFi"
echo.
echo ========================================================
echo.
echo [Buoc 9] Ket noi WiFi cho loa
echo.
echo   1. Mo WiFi tren may tinh
echo.
echo   2. Ket noi vao mang WiFi: "Phicomm_R1"
echo.
echo   3. Mo trinh duyet web va nhap dia chi:
echo.
echo      http://192.168.43.1:8080
echo.
echo   4. Chon mang WiFi gia dinh va nhap mat khau
echo.
echo   5. Nhan "Ket noi" va doi thiet bi ket noi
echo.
echo ========================================================
echo.
echo Sau khi ket noi WiFi thanh cong, thiet bi se doc dia chi IP.
echo Ban co the su dung dia chi IP nay de ket noi ADB sau nay.
echo.
echo ========================================================
echo.
pause

echo.
echo Cam on ban da su dung VoiceBot AI!
echo.
timeout /t 3 >nul
exit
