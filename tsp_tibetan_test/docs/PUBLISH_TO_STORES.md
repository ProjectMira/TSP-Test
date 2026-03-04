# Publish to Google Play Store and Apple App Store

This guide explains the release flow in simple, step-by-step format.

## Before you start (both platforms)

1. Confirm app name, icon, and bundle IDs are final.
2. Update app version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1
   ```
3. Test app locally on Android and iOS.
4. Make sure signing credentials are ready.

---

## A) Publish to Google Play Store (Android)

### Step 1: Create app in Play Console

1. Go to Google Play Console.
2. Click **Create app**.
3. Fill app details (name, language, app/game, free/paid).
4. Complete required Play Console setup sections.

### Step 2: Prepare signing

1. Create an upload keystore (if you do not already have one):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Save keystore file and passwords safely.
3. Configure signing in Android project (`android/key.properties` and Gradle signing config).

### Step 3: Build release bundle

From `tsp_tibetan_test`:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output file:

`build/app/outputs/bundle/release/app-release.aab`

### Step 4: Create release in Play Console

1. Open your app in Play Console.
2. Go to **Testing** (Internal/Closed/Open) or **Production**.
3. Click **Create new release**.
4. Upload `app-release.aab`.
5. Add release notes.
6. Review warnings and save.

### Step 5: Complete store listing and policies

1. Fill app description, screenshots, icon, feature graphic.
2. Complete content rating.
3. Complete Data safety form.
4. Set app access and ads declaration if required.

### Step 6: Submit for review

1. Go to **Publishing overview**.
2. Resolve any remaining issues.
3. Click **Send for review** / **Start rollout to production**.
4. Wait for Google review and approval.

---

## B) Publish to Apple App Store (iOS)

### Step 1: Create app in App Store Connect

1. Open App Store Connect.
2. Go to **My Apps** -> **+** -> **New App**.
3. Enter app name, primary language, bundle ID, SKU.

### Step 2: Configure signing in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select Runner target -> **Signing & Capabilities**.
3. Choose Apple Developer Team.
4. Set correct bundle identifier.
5. Ensure signing certificate and provisioning profile are valid.

### Step 3: Build iOS release archive

Option A (Flutter CLI build first):

```bash
flutter clean
flutter pub get
flutter build ios --release
```

Option B (Archive in Xcode):

1. In Xcode, choose **Any iOS Device (arm64)**.
2. Menu: **Product** -> **Archive**.
3. Wait for archive to complete.

### Step 4: Upload build to App Store Connect

1. After archive, Xcode Organizer opens.
2. Select archive -> **Distribute App**.
3. Choose **App Store Connect** -> **Upload**.
4. Complete upload flow.

### Step 5: Prepare app listing

1. In App Store Connect, open your app version.
2. Add screenshots, description, keywords, support URL, marketing URL (if needed).
3. Fill App Privacy details.
4. Select the uploaded build.

### Step 6: Submit for review

1. Complete required compliance questions.
2. Click **Submit for Review**.
3. Wait for Apple review status updates.
4. After approval, release manually or automatically based on your release option.

---

## Release checklist

- [ ] Version updated in `pubspec.yaml`
- [ ] Android AAB built and uploaded
- [ ] iOS archive uploaded
- [ ] Store metadata complete (screenshots, description, privacy)
- [ ] Policies and compliance forms complete
- [ ] Submitted for review on both stores
