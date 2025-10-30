@echo off
echo ================================
echo Panda in the Garden - Flutter App Setup
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Flutter found!
flutter --version | findstr /r "^Flutter"
echo.

REM Navigate to project directory
cd /d "%~dp0"

REM Get dependencies
echo Installing dependencies...
call flutter pub get

REM Check for connected devices
echo.
echo Checking for connected devices...
call flutter devices

echo.
echo ================================
echo Setup complete!
echo ================================
echo.
echo To run the app, use one of these commands:
echo   flutter run                    - Run on connected device
echo   flutter run -d chrome          - Run in Chrome (web)
echo   flutter run -d windows         - Run on Windows (desktop)
echo   flutter run -d android         - Run on Android emulator
echo.
echo Test Credentials:
echo   Panda: panda@garden.com / panda123
echo   Visitor: alice@example.com / visitor123
echo.
echo Happy gardening!
echo.
pause
