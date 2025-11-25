# FVM Setup Instructions

This project uses FVM (Flutter Version Management) to manage the Flutter SDK version.

## ⚠️ CRITICAL: Use FVM Commands

**IMPORTANT:** Always use `fvm flutter` instead of `flutter` for all Flutter commands.

**DO NOT use:**
- ❌ `flutter build apk`
- ❌ `flutter build aab`
- ❌ `flutter pub get`

**USE INSTEAD:**
- ✅ `fvm flutter build apk --release`
- ✅ `fvm flutter build appbundle --release`
- ✅ `fvm flutter pub get`

### Common Commands:

```bash
# Get dependencies
fvm flutter pub get

# Run the app
fvm flutter run

# Build APK
fvm flutter build apk --release

# Build App Bundle
fvm flutter build appbundle --release

# Clean build
fvm flutter clean

# Doctor check
fvm flutter doctor
```

## Current Flutter Version

- **Flutter Version:** 3.38.3 (stable)
- **Dart Version:** 3.10.1

## Setup (if needed)

If you haven't set up FVM yet:

```bash
# Install FVM globally
dart pub global activate fvm

# Install Flutter stable version
fvm install stable

# Use stable version for this project
fvm use stable
```

## VS Code Integration

FVM should automatically configure VS Code. If not, restart VS Code after running `fvm use stable`.

## Troubleshooting Build Errors

If you encounter build errors:

1. **Clean build directories:**
   ```powershell
   .\clean-build.ps1
   ```

2. **Clean Flutter:**
   ```bash
   fvm flutter clean
   ```

3. **Get dependencies:**
   ```bash
   fvm flutter pub get
   ```

4. **Rebuild:**
   ```bash
   fvm flutter build apk --release
   ```

## What Was Fixed

1. ✅ Fixed `settings.gradle.kts` - Removed version from flutter-plugin-loader
2. ✅ Added multidex support to handle large app sizes
3. ✅ Set up FVM with Flutter 3.38.3 (stable)
4. ✅ Created cleanup script for build directory issues
5. ✅ Updated `.gitignore` to track FVM config

