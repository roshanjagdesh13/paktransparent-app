# Fix Java Version Issue

## Problem
Java 25 is too new for Gradle. We need Java 21 (LTS).

## Solution: Download & Install Java 21

### Step 1: Download Java 21
Go to: https://adoptium.net/temurin/releases/

**Or use this direct link:**
https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_windows_hotspot_21.0.6_7.msi

Click download and install the MSI file.

### Step 2: Install Java 21
- Run the downloaded .msi file
- **Important:** Check the box "Add to PATH" during installation
- Click Next, Next, Install
- Wait for installation to complete

### Step 3: Configure Flutter to Use Java 21
Open PowerShell and run:

```powershell
flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot"
```

**Note:** Path might be slightly different. Check: `C:\Program Files\Eclipse Adoptium\`

### Step 4: Verify
```powershell
flutter doctor -v
```

Should show Java 21.
andr
### Step 5: Build Your App
```powershell
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Existing Java 8

If download is slow, use Java 8 (already on your system):

```powershell
flutter config --jdk-dir="C:\Program Files\Java\jre1.8.0_481"
```

Then:
```powershell
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"
flutter clean
flutter pub get
flutter run
```

This should work!
