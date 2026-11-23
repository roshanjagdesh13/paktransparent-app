# PakTransparent App - Installation Guide for Android

## Current Status
✅ Android SDK/ADB is installed  
❌ Flutter SDK needs to be installed

---

## Step 1: Install Flutter SDK

### Option A: Download and Install Manually
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract the zip file to: `C:\flutter` (or your preferred location)
3. Add Flutter to your PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" under System Variables
   - Add: `C:\flutter\bin`
   - Click OK to save

### Option B: Use Git to Clone Flutter
```powershell
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```
Then add `C:\flutter\bin` to your PATH as described above.

---

## Step 2: Verify Flutter Installation

Open a new PowerShell window and run:
```powershell
flutter doctor
```

This will check your environment and show what else needs to be configured.

---

## Step 3: Accept Android Licenses

Run this command to accept all Android SDK licenses:
```powershell
flutter doctor --android-licenses
```

Press 'y' to accept all licenses.

---

## Step 4: Prepare Your Android Device

### On Your Phone:
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**
5. Connect your phone to PC via USB cable
6. On your phone, accept the "Allow USB Debugging" prompt

### Verify Device Connection:
```powershell
adb devices
```

You should see your device listed. If it shows "unauthorized", check your phone for the authorization prompt.

---

## Step 5: Navigate to Flutter Project

```powershell
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"
```

---

## Step 6: Get Flutter Dependencies

```powershell
flutter pub get
```

This downloads all required packages defined in `pubspec.yaml`.

---

## Step 7: Check Connected Devices

```powershell
flutter devices
```

This should show your connected Android device.

---

## Step 8: Build and Install the App

### Option A: Debug Build (Faster, for testing)
```powershell
flutter run
```

### Option B: Release Build (Optimized, smaller size)
```powershell
flutter build apk --release
```

The APK will be created at:
`build\app\outputs\flutter-apk\app-release.apk`

### Option C: Install Release APK Directly
```powershell
flutter build apk --release
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## Step 9: Troubleshooting

### If Flutter command not found after installation:
- Close and reopen PowerShell
- Verify PATH is set correctly
- Run: `$env:Path` to check if Flutter bin directory is included

### If device not detected:
```powershell
# Restart ADB server
adb kill-server
adb start-server
adb devices
```

### If build fails due to missing dependencies:
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### Check for specific Android issues:
```powershell
flutter doctor -v
```

---

## Quick Commands Summary (After Flutter is Installed)

```powershell
# Navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# Get dependencies
flutter pub get

# Check devices
flutter devices

# Run in debug mode (hot reload enabled)
flutter run

# Build release APK
flutter build apk --release

# Install on connected device
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## Expected Output

Once successful, you'll see the **PakTransparent** app installed on your Android phone with the Pakistan flag icon, ready to track public budget and government projects.

---

## Need Help?

If you encounter any errors during the process, share the error message and I'll help you resolve it.
