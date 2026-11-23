@echo off
echo ========================================
echo PakTransparent - Fix and Build Script
echo ========================================
echo.

echo [Step 1/6] Stopping Gradle daemons...
cd android
call gradlew --stop
cd ..
echo Done!
echo.

echo [Step 2/6] Cleaning Flutter build cache...
call flutter clean
echo Done!
echo.

echo [Step 3/6] Clearing Gradle cache...
rmdir /s /q build 2>nul
rmdir /s /q android\.gradle 2>nul
rmdir /s /q android\app\build 2>nul
rmdir /s /q android\build 2>nul
echo Done!
echo.

echo [Step 4/6] Getting Flutter dependencies...
call flutter pub get
echo Done!
echo.

echo [Step 5/6] Checking device connection...
call flutter devices
echo.

echo [Step 6/6] Building and installing app...
echo This will take 5-15 minutes on first build...
echo Please wait...
echo.
call flutter run

echo.
echo ========================================
echo Build process completed!
echo ========================================
pause
