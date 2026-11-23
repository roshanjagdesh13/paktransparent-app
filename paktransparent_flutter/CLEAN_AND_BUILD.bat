@echo off
echo ========================================
echo COMPLETE CLEAN AND BUILD
echo ========================================
echo.

echo [1/7] Killing all Java processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 3 >nul
echo Done!
echo.

echo [2/7] Stopping all Gradle daemons...
cd android
call gradlew --stop 2>nul
cd ..
echo Done!
echo.

echo [3/7] Cleaning Flutter...
call flutter clean
echo Done!
echo.

echo [4/7] Removing Gradle cache...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"
if exist "android\build" rmdir /s /q "android\build"
echo Done!
echo.

echo [5/7] Getting Flutter dependencies...
call flutter pub get
echo Done!
echo.

echo [6/7] Building APK (15-20 minutes)...
echo Please be patient...
echo.
call flutter build apk --debug
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo SUCCESS! APK Created!
    echo ========================================
    echo.
    echo [7/7] Installing on your phone...
    call adb install -r build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo ========================================
    echo DONE! App installed!
    echo ========================================
) else (
    echo ========================================
    echo Build failed
    echo ========================================
)

echo.
pause
