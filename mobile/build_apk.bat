@echo off
echo Building SwiftShare Mobile APK...
echo.

echo Installing dependencies...
flutter pub get

echo.
echo Building release APK...
flutter build apk --release

echo.
echo APK build completed!
echo The APK file is located at: build\app\outputs\flutter-apk\app-release.apk
echo.
pause 