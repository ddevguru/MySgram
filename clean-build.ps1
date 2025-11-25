# PowerShell script to clean Flutter build directories
# Run this script if you encounter build errors

Write-Host "Cleaning Flutter build directories..." -ForegroundColor Yellow

# Clean Flutter build
if (Test-Path "build") {
    Write-Host "Removing build directory..." -ForegroundColor Cyan
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean Android build directories
if (Test-Path "android\build") {
    Write-Host "Removing android\build directory..." -ForegroundColor Cyan
    Remove-Item -Path "android\build" -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path "android\.gradle") {
    Write-Host "Removing android\.gradle directory..." -ForegroundColor Cyan
    Remove-Item -Path "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path "android\app\build") {
    Write-Host "Removing android\app\build directory..." -ForegroundColor Cyan
    Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean .dart_tool
if (Test-Path ".dart_tool") {
    Write-Host "Removing .dart_tool directory..." -ForegroundColor Cyan
    Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`nCleaning completed! Now run: fvm flutter clean" -ForegroundColor Green
Write-Host "Then: fvm flutter pub get" -ForegroundColor Green
Write-Host "Finally: fvm flutter build apk --release" -ForegroundColor Green

