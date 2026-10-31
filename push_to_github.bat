@echo off
chcp 65001 >nul
echo ========================================================
echo       LUMYRA Platform - Push to GitHub Repository
echo ========================================================
echo Target: https://github.com/bassiony58-ux/LUMYRA.git
echo.
git status
echo.
echo Attempting git push...
git push -u origin main
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo --------------------------------------------------------
    echo [تنبيه التوثيق / Authentication Guide]
    echo لرفع المشروع بنجاح إلى حسابك:
    echo 1. تأكد من إنشاء مستودع فارغ باسم LUMYRA على: https://github.com/new
    echo 2. سجل دخولك إلى جيت هاب بكتابة:
    echo    gh auth login
    echo أو استخدم التوكن الخاص بك (Personal Access Token):
    echo    git remote set-url origin https://<YOUR_GITHUB_TOKEN>@github.com/bassiony58-ux/LUMYRA.git
    echo    git push -u origin main
    echo --------------------------------------------------------
)
pause
