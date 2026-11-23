@echo off
echo ========================================
echo PakTransparent App - System Check
echo ========================================
echo.

echo Checking Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Flutter NOT FOUND
    echo.
    echo SOLUTION: Install Flutter from https://docs.flutter.dev/get-started/install/windows
    echo After installing, add C:\flutter\bin to your PATH
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Flutter found
    flutter --version
)

echo.
echo Checking Android SDK...
where adb >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Android SDK NOT FOUND
    pause
    exit /b 1
) else (
    echo [OK] Android SDK found
)

echo.
echo Checking connected devices...
adb devices
echo.

echo ========================================
echo If your device is listed above, you can:
echo 1. Open this project in Android Studio
echo 2. Click the green Run button
echo ========================================
echo.

echo Do you want me to try opening Android Studio? (Y/N)
set /p choice=Enter choice: 

if /i "%choice%"=="Y" (
    echo Opening Android Studio...
    start "" "C:\Program Files\Android\Android Studio\bin\studio64.exe" "%~dp0"
    echo.
    echo Android Studio should open now.
    echo Once opened:
    echo 1. Wait for Gradle sync
    echo 2. Select your device from dropdown at top
    echo 3. Click green Run button
)

pause
