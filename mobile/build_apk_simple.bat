@echo off
echo ========================================
echo SwiftShare Mobile APK Builder
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building APK (this may take a few minutes)...
echo If you see timeout errors, the build will retry automatically.
echo.

flutter build apk --release --verbose

echo.
echo ========================================
echo Build Status Check
echo ========================================
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo SUCCESS! APK built successfully.
    echo.
    echo APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo APK Size: 
    dir "build\app\outputs\flutter-apk\app-release.apk" | find "app-release.apk"
    echo.
    echo You can now install this APK on your Android device!
) else (
    echo ERROR: APK build failed.
    echo.
    echo Troubleshooting steps:
    echo 1. Make sure you have Android SDK installed
    echo 2. Try running: flutter doctor
    echo 3. Check your internet connection
    echo 4. Try running the build again
)

echo.
pause 