@echo off
chcp 65001 >nul
title LUMYRA Platform - تشغيل النظام بالكامل
color 0B

echo ===================================================================
echo             🌸 منصة لوميرا (LUMYRA) - تشغيل كافة الخدمات 🌸
echo ===================================================================
echo.

echo [1/3] فحص وتوصيل الموبايل عبر ADB Reverse...
set ADB="%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if exist %ADB% (
    %ADB% start-server >nul 2>&1
    %ADB% reverse tcp:4000 tcp:4000 >nul 2>&1
    %ADB% reverse tcp:3000 tcp:3000 >nul 2>&1
    echo    ✓ تم ربط منافذ الهاتف (Port 4000 ^& 3000) بالكمبيوتر بنجاح!
) else (
    echo    ! تنبيه: لم يتم العثور على adb تلقائياً.
)

echo.
echo [2/3] تشغيل سيرفر الويب والملفات (Port 3000)...
start "LUMYRA - Web Server (Port 3000)" cmd /k "cd /d M:\LUMYRA && node server.cjs"

echo.
echo [3/3] تشغيل الباك إند والذكاء الاصطناعي (Port 4000)...
start "LUMYRA - Backend NestJS (Port 4000)" cmd /k "cd /d M:\LUMYRA\backend && npm run start"

echo.
echo ===================================================================
echo    🎉 تم تشغيل كافة خوادم النظام بنجاح!
echo ===================================================================
echo.
echo • للموبايل:
echo    - وصّل كابل الـ USB وافتح تطبيق "Lumyra" المثبت على هاتفك مباشرة!
echo.
echo • للكمبيوتر / المتصفح:
echo    - لوحة الإدارة والموقع: http://localhost:3000
echo    - ملف دليل الفريق (PDF): http://localhost:3000/guide.pdf
echo    - فحص السيرفر والـ API: http://localhost:4000/api/v1/health
echo.
echo (اترك النوافذ المفتوحة تعمل في الخلفية أثناء الاستخدام)
echo ===================================================================
pause
