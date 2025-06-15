@echo off
echo ===================================================
echo Vuet Flutter App - Build and Run Script
echo ===================================================
echo.

:: Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Flutter is not installed or not in your PATH.
  echo Please install Flutter from https://flutter.dev/docs/get-started/install
  exit /b 1
)

:: Check Flutter version
echo Checking Flutter version...
flutter --version
echo.

:: Get Flutter dependencies
echo Installing dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
  echo Failed to get dependencies.
  exit /b 1
)
echo Dependencies installed successfully.
echo.

:: Clean the project
echo Cleaning project...
flutter clean
if %ERRORLEVEL% NEQ 0 (
  echo Warning: Clean operation failed, continuing anyway.
)
echo.

:: Run code generation for Freezed models
echo Running code generation...
flutter pub run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 (
  echo Failed to run code generation.
  exit /b 1
)
echo Code generation completed successfully.
echo.

:: Ensure .env file exists
if not exist .env (
  echo Creating default .env file...
  echo SUPABASE_URL=https://vhiwshayajhjmrouddqi.supabase.co> .env
  echo SUPABASE_ANON_KEY=sbp_e832ee2904c34a851c5bc10116f3a1e3d633f0f0>> .env
  echo SENTRY_DSN=>> .env
  echo Default .env file created.
  echo.
)

:: Choose platform to run
echo Choose platform to run:
echo 1. Web
echo 2. Android
echo 3. iOS (requires macOS)
echo 4. Windows
echo 5. Generate release build for web

set /p platform="Enter choice (1-5): "

if "%platform%"=="1" (
  echo.
  echo Running app on Chrome...
  flutter run -d chrome
) else if "%platform%"=="2" (
  echo.
  echo Running app on Android...
  flutter run -d android
) else if "%platform%"=="3" (
  echo.
  echo Running app on iOS...
  flutter run -d ios
) else if "%platform%"=="4" (
  echo.
  echo Running app on Windows...
  flutter run -d windows
) else if "%platform%"=="5" (
  echo.
  echo Building web release...
  flutter build web --release
  echo.
  echo Web build completed. Files are in build/web directory.
  echo You can deploy these files to any web hosting service.
) else (
  echo.
  echo Invalid choice. Exiting.
  exit /b 1
)

echo.
echo Script completed.
