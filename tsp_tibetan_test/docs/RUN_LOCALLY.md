# Run Locally (Android and iOS)

This guide is for testing the app on your local machine.

## 1) Prerequisites

- Flutter SDK installed
- Xcode installed (for iOS, macOS only)
- Android Studio installed (for Android emulator and SDK)
- A device or emulator/simulator

## 2) Open the project

From the repository root:

```bash
cd tsp_tibetan_test
```

Install dependencies:

```bash
flutter pub get
```

Check your setup:

```bash
flutter doctor
```

If `flutter doctor` shows issues, fix them first before running the app.

## 3) Run on Android

### Option A: Using Android Emulator (Recommended)

1. **Check available emulators:**
   ```bash
   flutter emulators
   ```

2. **Launch an Android emulator:**
   ```bash
   flutter emulators --launch <emulator-id>
   ```
   Example: `flutter emulators --launch Medium_Phone_API_36.0`

3. **Verify emulator is running:**
   ```bash
   flutter devices
   ```
   You should see an Android device listed (e.g., "sdk gphone64 arm64").

4. **Run the app:**
   ```bash
   flutter run -d android
   ```
   Or use the specific emulator ID:
   ```bash
   flutter run -d <emulator-device-id>
   ```
   Example: `flutter run -d emulator-5554`

### Option B: Using Physical Android Device

1. **Enable Developer Options and USB Debugging** on your Android device:
   - Go to Settings > About phone
   - Tap "Build number" 7 times to enable Developer options
   - Go to Settings > Developer options
   - Enable "USB debugging"

2. **Connect device via USB** and verify it's detected:
   ```bash
   flutter devices
   ```

3. **Run the app:**
   ```bash
   flutter run -d android
   ```

### Troubleshooting Android

- If no Android devices found, run `flutter emulators` to see available emulators
- If `flutter doctor` shows Android issues, ensure Android Studio and SDK are properly installed
- First-time builds may take several minutes to complete

## 4) Run on iOS (macOS only)

1. Start an iOS Simulator:
   ```bash
   open -a Simulator
   ```
2. Install iOS pods:
   ```bash
   cd ios && pod install && cd ..
   ```
3. Verify simulator/device is visible:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run -d ios
   ```

If you have multiple iOS devices/simulators, use the exact device ID:

```bash
flutter run -d <device-id>
```

## 5) Useful commands

### During Development
- **Hot reload**: press `r` in the terminal where `flutter run` is active
- **Full restart**: press `R`
- **Quit**: press `q`
- **List devices**: `flutter devices`
- **List emulators**: `flutter emulators`

### Testing and Building
- **Run tests**:
  ```bash
  flutter test
  ```
- **Check for outdated packages**:
  ```bash
  flutter pub outdated
  ```
- **Update dependencies**:
  ```bash
  flutter pub upgrade
  ```

### Release Builds
- **Build Android release APK**:
  ```bash
  flutter build apk --release
  ```
- **Build Android App Bundle (for Play Store)**:
  ```bash
  flutter build appbundle --release
  ```
- **Build iOS release (no codesign)**:
  ```bash
  flutter build ios --release --no-codesign
  ```

### Debugging
- **Flutter doctor with verbose output**:
  ```bash
  flutter doctor -v
  ```
- **Clean build cache**:
  ```bash
  flutter clean && flutter pub get
  ```
