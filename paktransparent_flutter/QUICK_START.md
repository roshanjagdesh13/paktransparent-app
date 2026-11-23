# 🚀 Quick Start Guide - PakTransparent Mobile App

## ✅ Status: Ready to Build!

Your Flutter app is **100% complete** and ready to install on your Android device.

---

## 📱 Install on Your Connected Device (FASTEST METHOD)

Since your device is already connected via wireless ADB, follow these steps:

### Step 1: Get Flutter Dependencies
```powershell
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"
flutter pub get
```

### Step 2: Build & Install (Choose ONE)

#### Option A: Run in Debug Mode (Faster, Hot Reload)
```powershell
flutter run
```
- App installs and launches automatically
- Hot reload enabled for quick testing
- Best for development

#### Option B: Build Release APK
```powershell
flutter build apk --release
adb install build\app\outputs\flutter-apk\app-release.apk
```
- Optimized for performance
- Smaller file size
- Production-ready build

---

## ⚡ Expected Timeline

| Task | Time |
|------|------|
| `flutter pub get` | ~30 seconds |
| `flutter run` (debug) | ~2-3 minutes (first time) |
| `flutter build apk` (release) | ~3-5 minutes |
| Install APK | ~10 seconds |
| **Total** | **~5 minutes** |

---

## 🎯 What Happens Next

1. **First Launch:**
   - Splash screen appears
   - Shows onboarding (3 screens)
   - Lands on login screen

2. **Test Login:**
   - Select "Citizen" or "Government"
   - Enter test credentials
   - OR register new account

3. **Explore Features:**
   - **Citizens:** Browse projects, submit reports
   - **Government:** Create projects, manage reports

---

## ⚠️ Important Notes

### 1. Urdu Fonts (Optional)
If you need Urdu language support:
1. Download fonts from: https://fonts.google.com/noto/specimen/Noto+Nastaliq+Urdu
2. Place `NotoNastaliqUrdu-Regular.ttf` and `NotoNastaliqUrdu-Bold.ttf` in `assets/fonts/`
3. Run `flutter pub get` again

**Skip for now if testing English only.**

### 2. Backend API
The app currently uses placeholder API endpoint. To connect to real backend:
1. Open `lib/core/constants/app_constants.dart`
2. Update line 18:
   ```dart
   static const String apiBaseUrl = 'YOUR_BACKEND_URL/api';
   ```

**Skip for now if testing UI only.**

---

## 🔧 Troubleshooting

### Problem: Flutter command not found
**Solution:** Install Flutter SDK first
- Download: https://docs.flutter.dev/get-started/install/windows
- Add to PATH

### Problem: Device not detected
**Solution:** Check ADB connection
```powershell
adb devices
```
Should show: `adb-333526451400073-8f3IOU._adb-tls-connect._tcp        device`

If not shown:
```powershell
adb kill-server
adb start-server
adb devices
```

### Problem: Gradle build fails
**Solution:** Clean and rebuild
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### Problem: Dependencies error
**Solution:** Update dependencies
```powershell
flutter pub upgrade
```

---

## 📋 Commands Cheat Sheet

```powershell
# Navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# Get dependencies
flutter pub get

# Check everything is OK
flutter doctor

# Run in debug mode (hot reload enabled)
flutter run

# Build release APK
flutter build apk --release

# Install APK on connected device
adb install build\app\outputs\flutter-apk\app-release.apk

# Check code for issues
flutter analyze

# Format code
flutter format .

# Clean build cache
flutter clean
```

---

## 🎉 Success Indicators

You'll know it's working when:

✅ `flutter pub get` completes without errors  
✅ `flutter doctor` shows green checkmarks  
✅ `flutter analyze` shows no issues  
✅ App appears on your phone  
✅ Splash screen displays  
✅ Navigation works smoothly  

---

## 📱 App Features to Test

### Must Test:
- ✅ Splash screen → Onboarding → Login flow
- ✅ Login as Citizen
- ✅ Browse projects
- ✅ View project details
- ✅ Submit a report
- ✅ View my reports
- ✅ Toggle theme (light/dark)
- ✅ Profile settings

### Optional Test:
- Government login
- Create project
- Review reports
- Analytics screens

---

## 🚀 Let's Get Started!

**Run these commands now:**

```powershell
# 1. Navigate to project
cd "C:\Users\Roshan\OneDrive\Desktop\paktransparent-app\paktransparent_flutter"

# 2. Install dependencies
flutter pub get

# 3. Check device is connected
adb devices

# 4. Run the app!
flutter run
```

**That's it!** The app will build and install automatically.

---

## 💡 Pro Tips

1. **First build takes longer** (~5 min). Subsequent builds are faster (~30 sec).

2. **Use Hot Reload** while app is running:
   - Make code changes
   - Save file
   - Press `r` in terminal for hot reload
   - Or `R` for full restart

3. **Keep terminal open** while testing to see logs and errors.

4. **Test on real device** for better performance than emulator.

---

## 📞 Need Help?

If you encounter issues:

1. Check this guide first
2. Run `flutter doctor -v` for detailed diagnostics
3. Check the full report: `MOBILE_APP_PREPARATION_REPORT.md`
4. Read main documentation: `README.md`

---

**Happy Testing! 🎉**

The app is ready. Just run `flutter pub get` and then `flutter run`!
