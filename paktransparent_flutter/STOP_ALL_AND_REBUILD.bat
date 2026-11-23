@echo off
echo ========================================
echo EMERGENCY FIX - Stop All Daemons
echo ========================================
echo.

echo [1/8] Killing all Java processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 2 >nul
echo Done!
echo.

echo [2/8] Stopping Gradle daemons...
cd android
call gradlew --stop 2>nul
cd ..
echo Done!
echo.

echo [3/8] Cleaning Flutter build...
call flutter clean
echo Done!
echo.

echo [4/8] Removing all build folders...
if exist "build" rmdir /s /q "build"
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"
if exist "android\build" rmdir /s /q "android\build"
if exist "android\.idea" rmdir /s /q "android\.idea"
echo Done!
echo.

echo [5/8] Clearing Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
if exist "%USERPROFILE%\.gradle\daemon" rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
echo Done!
echo.

echo [6/8] Getting Flutter dependencies...
call flutter pub get
echo Done!
echo.

echo [7/8] Checking device connection...
call flutter devices
echo.

echo [8/8] Building APK (without daemon issues)...
echo This will take 10-20 minutes...
echo IMPORTANT: Do NOT close this window!
echo.
call flutter build apk --debug
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo SUCCESS! APK built successfully!
    echo ========================================
    echo.
    echo APK Location:
    echo build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo [9/8 BONUS] Installing on device...
    call adb install build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo ========================================
    echo Build failed. Check errors above.
    echo ========================================
)

echo.
pause
