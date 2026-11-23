# ✅ Build & Install Checklist

## 🎯 Goal: Install PakTransparent App on Your Android Device

Follow these simple steps to get your app running!

---

## 📋 Pre-Flight Check

### Required Software
- [ ] Flutter SDK installed
  - Check: Run `flutter --version` in PowerShell
  - Install: https://docs.flutter.dev/get-started/install/windows

- [ ] Android device connected
  - Check: Run `adb devices` in PowerShell
  - Should show your device ID

### Optional (Can Skip)
- [ ] Urdu fonts downloaded (only if you need Urdu language)
- [ ] Backend API configured (only if connecting to real server)

---

## 🚀 Build & Install (Choose ONE Method)

### METHOD 1: Quick Run (RECOMMENDED) ⚡

**Time:** ~3 minutes

```powershell
# 1. Open PowerShell and navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

**✅ Done!** App installs and launches automatically on your phone.

---

### METHOD 2: Build APK File 📦

**Time:** ~5 minutes

```powershell
# 1. Open PowerShell and navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# 2. Get dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release

# 4. Install on connected device
adb install build\app\outputs\flutter-apk\app-release.apk
```

**✅ Done!** APK file created and installed.

**APK Location:** `build\app\outputs\flutter-apk\app-release.apk`

---

## 🎉 Success Indicators

You'll know it worked when:

✅ Terminal shows "Flutter run complete"  
✅ App icon appears on your phone  
✅ Splash screen displays when launched  
✅ Can navigate through screens  

---

## 🐛 Troubleshooting

### ❌ Problem: "flutter command not found"
**Solution:** Flutter SDK not installed or not in PATH
```powershell
# Check if Flutter is installed
flutter --version
```
If error: Install Flutter from https://docs.flutter.dev/get-started/install/windows

---

### ❌ Problem: "No devices found"
**Solution:** Device not connected
```powershell
# Check device connection
adb devices

# If not showing, restart ADB
adb kill-server
adb start-server
adb devices
```

---

### ❌ Problem: "Build failed"
**Solution:** Clean and rebuild
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

---

### ❌ Problem: "Gradle build error"
**Solution:** This is normal for first build, just wait
- First build takes 3-5 minutes
- Gradle is downloading dependencies
- Be patient!

---

## ⏱️ Expected Wait Times

| Task | First Time | Next Time |
|------|------------|-----------|
| `flutter pub get` | 30-60 sec | 5-10 sec |
| `flutter run` | 3-5 min | 30-60 sec |
| `flutter build apk` | 3-5 min | 1-2 min |
| APK install | 10 sec | 10 sec |

---

## 📱 After Installation

### First Launch
1. Splash screen appears (2 seconds)
2. Onboarding screens (3 pages) - swipe through
3. Login screen

### Test the App
- [ ] Create an account (Citizen or Government)
- [ ] Browse projects
- [ ] View project details
- [ ] Submit a test report
- [ ] Toggle dark mode in settings
- [ ] Try different features

---

## 💡 Pro Tips

1. **Keep PowerShell open** while testing to see logs
2. **Press R** in terminal for hot reload while running
3. **Use real device** for best performance
4. **First build is slow**, subsequent builds are faster

---

## 📞 Need Help?

If something goes wrong:

1. **Check this list first** ☝️
2. **Run diagnostics:**
   ```powershell
   flutter doctor -v
   ```
3. **Read the full guide:**
   - `QUICK_START.md`
   - `README.md`
   - `MOBILE_APP_PREPARATION_REPORT.md`

---

## ✨ Quick Commands Reference

```powershell
# Navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# Get dependencies (always run first!)
flutter pub get

# Check setup
flutter doctor

# Check device
adb devices

# Run on device (debug)
flutter run

# Build APK (release)
flutter build apk --release

# Install APK
adb install build\app\outputs\flutter-apk\app-release.apk

# Check for code issues
flutter analyze

# Clean build cache
flutter clean
```

---

## 🎯 Your Next Command

If Flutter is installed, just copy and paste this:

```powershell
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter" ; flutter pub get ; flutter run
```

**That's ONE command to do everything!** ⚡

---

**Good luck! Your app is ready to install! 🚀📱**

---

**Created:** September 27, 2026  
**Project:** PakTransparent Mobile App  
**Version:** 1.0.0
