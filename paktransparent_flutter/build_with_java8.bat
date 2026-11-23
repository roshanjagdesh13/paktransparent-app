@echo off
echo Setting Java 8 for Flutter build...
set JAVA_HOME=C:\Program Files\Java\jre1.8.0_481
set PATH=%JAVA_HOME%\bin;%PATH%

echo.
echo Cleaning previous build...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building and installing app...
call flutter run

pause
