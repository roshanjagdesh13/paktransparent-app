@echo off
echo ========================================
echo PakTransparent - FINAL BUILD SOLUTION
echo ========================================
echo.
echo IMPORTANT: This will take 15-20 minutes
echo Do NOT close this window!
echo.
pause

echo [1/5] Killing all Java processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 3 >nul
echo Done!
echo.

echo [2/5] Cleaning Flutter build...
call flutter clean
echo Done!
echo.

echo [3/5] Getting dependencies...
call flutter pub get
echo Done!
echo.

echo [4/5] Building APK (this is the long part - 15-20 min)...
echo Please be patient and don't close this window!
echo.
call flutter build apk --debug --no-tree-shake-icons
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo SUCCESS! APK Created!
    echo ========================================
    echo.
    echo [5/5] Installing on your phone...
    call adb install -r build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo ========================================
    echo DONE! Check your phone!
    echo ========================================
    echo.
    echo App should now be installed on V2212
    echo Look for "PakTransparent" icon
) else (
    echo ========================================
    echo Build failed - see errors above
    echo ========================================
)

echo.
pause
