@echo off
echo ========================================
echo Building APK using Gradle (No Flutter)
echo ========================================
echo.

cd /d "%~dp0"

echo Setting Java 8...
set JAVA_HOME=C:\Program Files\Java\jre1.8.0_481
set PATH=%JAVA_HOME%\bin;%PATH%

echo.
echo Building APK... (This will take 3-5 minutes)
cd android
call gradlew.bat assembleRelease

echo.
echo ========================================
if exist "app\build\outputs\apk\release\app-release.apk" (
    echo [SUCCESS] APK built successfully!
    echo.
    echo APK Location:
    echo %~dp0android\app\build\outputs\apk\release\app-release.apk
    echo.
    echo To install on your phone:
    echo adb install app\build\outputs\apk\release\app-release.apk
) else (
    echo [FAILED] APK build failed. Check errors above.
)
echo ========================================

pause
