@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title Cài đặt VoiceBot AI cho Phicomm R1

:menu
cls
echo.
echo ========================================================
echo       CÀI ĐẶT VOICEBOT AI CHO PHICOMM R1
echo ========================================================
echo.

REM Bước 1: Hướng dẫn vào chế độ phát wifi
echo [Bước 1] Chuẩn bị thiết bị
echo.
echo   Vui lòng GIỮ NÚT trên loa trong 10 giây để vào 
echo   chế độ phát WiFi (đèn trắng phát sáng nhấp nháy)
echo.
echo --------------------------------------------------------
echo.
echo [Bước 2] Kết nối WiFi từ máy tính
echo.
echo   Mở WiFi trên máy tính và tìm mạng: Phicomm_R1_xxx
echo   (xxx là các ký tự bất kỳ)
echo   Kết nối tới mạng WiFi đó.
echo.
echo --------------------------------------------------------

REM Bước 3: Xác nhận đã kết nối WiFi
:confirm_wifi
echo.
set /p confirm="Đã kết nối tới WiFi Phicomm_R1_xxx chưa? (Y/N): "
if /i "!confirm!"=="Y" goto connect_adb
if /i "!confirm!"=="N" (
    echo.
    echo Vui lòng thực hiện lại việc giữ nút trên loa...
    goto confirm_wifi
)
echo Vui lòng nhập Y hoặc N
goto confirm_wifi

REM Bước 4: Kết nối ADB TCP
:connect_adb
cls
echo.
echo [Bước 3] Kết nối ADB đến thiết bị
echo.
echo Đang dọn dẹp các tiến trình ADB cũ...
adb disconnect >nul 2>&1
taskkill /f /t /im adb.exe >nul 2>&1
timeout /t 2 >nul
adb devices >nul 2>&1

echo.
echo Đang kết nối đến 192.168.43.1:5555...
echo.
adb connect 192.168.43.1:5555

REM Kiểm tra kết nối
adb devices | findstr /ic "192.168.43.1:5555" | findstr /ic "device" >nul
if errorlevel 1 (
    echo.
    echo [LỖI] Không thể kết nối đến thiết bị!
    echo.
    echo Vui lòng kiểm tra:
    echo   1. Máy tính đã kết nối WiFi "Phicomm_R1" chưa?
    echo   2. Loa đã vào chế độ phát WiFi chưa?
    echo.
    pause
    goto menu
)

echo.
echo [OK] Kết nối ADB thành công!
echo.
timeout /t 2 >nul

REM Bước 5: Tắt các service không cần thiết
cls
echo.
echo [Bước 4] Tắt các ứng dụng không cần thiết trên loa
echo.
echo Đang tắt com.phicomm.speaker.player...
adb shell /system/bin/pm hide com.phicomm.speaker.player
echo Đang tắt com.phicomm.speaker.device...
adb shell /system/bin/pm hide com.phicomm.speaker.device
echo Đang tắt com.phicomm.speaker.airskill...
adb shell /system/bin/pm hide com.phicomm.speaker.airskill
echo Đang tắt com.phicomm.speaker.exceptionreporter...
adb shell /system/bin/pm hide com.phicomm.speaker.exceptionreporter
echo Đang tắt com.phicomm.speaker.ijetty...
adb shell /system/bin/pm hide com.phicomm.speaker.ijetty
echo Đang tắt com.phicomm.speaker.netctl...
adb shell /system/bin/pm hide com.phicomm.speaker.netctl
echo Đang tắt com.phicomm.speaker.otaservice...
adb shell /system/bin/pm hide com.phicomm.speaker.otaservice
echo Đang tắt com.phicomm.speaker.systemtool...
adb shell /system/bin/pm hide com.phicomm.speaker.systemtool
echo Đang tắt com.phicomm.speaker.productiontest...
adb shell /system/bin/pm hide com.phicomm.speaker.productiontest
echo Đang tắt com.phicomm.speaker.bugreport...
adb shell /system/bin/pm hide com.phicomm.speaker.bugreport
echo.
echo [OK] Đã tắt các ứng dụng không cần thiết!
echo.
timeout /t 2 >nul

REM Bước 6: Push file APK lên thiết bị
cls
echo.
echo [Bước 5] Sao chép file cài đặt lên thiết bị
echo.

REM Kiểm tra file APK tồn tại
if not exist "%~dp0app-voicebot.apk" (
    echo [LỖI] Không tìm thấy file app-voicebot.apk!
    echo.
    echo Vui lòng đặt file app-voicebot.apk vào cùng thư mục với file bat này.
    echo.
    pause
    goto menu
)

echo Đang sao chép app-voicebot.apk lên thiết bị...
adb push "%~dp0app-voicebot.apk" /data/local/tmp/app-voicebot.apk
if errorlevel 1 (
    echo.
    echo [LỖI] Không thể sao chép file lên thiết bị!
    echo.
    pause
    goto menu
)
echo.
echo [OK] Sao chép file thành công!
echo.
timeout /t 2 >nul

REM Bước 7: Cài đặt APK
cls
echo.
echo [Bước 6] Cài đặt ứng dụng VoiceBot
echo.
echo Đang cài đặt...
adb shell /system/bin/pm install -r /data/local/tmp/app-voicebot.apk
if errorlevel 1 (
    echo.
    echo [LỖI] Cài đặt thất bại!
    echo.
    pause
    goto menu
)
echo.
echo [OK] Cài đặt ứng dụng thành công!
echo.
timeout /t 2 >nul

REM Bước 8: Thông báo hoàn tất cài đặt
cls
echo.
echo ========================================================
echo       CÀI ĐẶT HOÀN TẤT!
echo ========================================================
echo.
echo [Bước 7] Cấu hình WiFi cho thiết bị
echo.
echo   1. GIỮ NÚT trên loa đến khi nghe thấy:
echo      "Vào chế độ cài đặt WiFi"
echo.
echo --------------------------------------------------------
echo.
pause

REM Bước 9: Hướng dẫn cấu hình WiFi
cls
echo.
echo ========================================================
echo       CẤU HÌNH WIFI CHO THIẾT BỊ
echo ========================================================
echo.
echo   1. Mở WiFi trên máy tính
echo.
echo   2. Kết nối vào mạng WiFi: "Phicomm_R1" hoặc "VoiceBot_XXXX"
echo.
echo   3. Mở trình duyệt web và nhập địa chỉ:
echo.
echo      http://192.168.43.1:8080
echo.
echo   4. Chọn mạng WiFi gia đình và nhập mật khẩu
echo.
echo   5. Nhấn "Kết nối" và đợi thiết bị kết nối
echo.
echo ========================================================
echo.
echo Sau khi kết nối WiFi thành công, thiết bị sẽ đọc địa chỉ IP.
echo Bạn có thể sử dụng địa chỉ IP này để kết nối ADB sau này.
echo.
echo ========================================================
echo.
pause

echo.
echo Cảm ơn bạn đã sử dụng VoiceBot AI!
echo.
timeout /t 3 >nul
exit
