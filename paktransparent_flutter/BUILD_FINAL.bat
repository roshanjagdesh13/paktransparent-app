@echo off
echo ========================================
echo Building APK - Gradle 8.14
echo ========================================
echo.
echo This will take 15-20 minutes on first build
echo Please wait...
echo.

echo [1/2] Building APK...
call flutter build apk --debug
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo SUCCESS! APK Created!
    echo ========================================
    echo.
    echo APK Size:
    dir build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo [2/2] Installing on your phone...
    call adb install -r build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo ========================================
    echo DONE! App installed on V2212!
    echo ========================================
    echo.
    echo Check your phone for "PakTransparent" app
) else (
    echo ========================================
    echo Build failed - see errors above
    echo ========================================
)

echo.
pause
