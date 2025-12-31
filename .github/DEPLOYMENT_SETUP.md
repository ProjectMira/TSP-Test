# 🚀 App Store Deployment Setup Guide

This guide walks you through setting up automated deployment to Google Play Store (Android) and Apple App Store (iOS) using GitHub Actions.

---

## 📋 Table of Contents

1. [GitHub Secrets Overview](#github-secrets-overview)
2. [Android Setup (Google Play Store)](#android-setup-google-play-store)
3. [iOS Setup (Apple App Store)](#ios-setup-apple-app-store)
4. [Triggering Releases](#triggering-releases)
5. [Troubleshooting](#troubleshooting)

---

## 🔐 GitHub Secrets Overview

Navigate to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### Required Secrets

| Secret Name | Platform | Description |
|-------------|----------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Android | Base64-encoded keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Android | Keystore password |
| `ANDROID_KEY_PASSWORD` | Android | Key password |
| `ANDROID_KEY_ALIAS` | Android | Key alias name |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Android | Google Play API credentials |
| `APPLE_CERTIFICATE_P12_BASE64` | iOS | Base64-encoded distribution certificate |
| `APPLE_CERTIFICATE_PASSWORD` | iOS | Certificate password |
| `APPLE_PROVISIONING_PROFILE_BASE64` | iOS | Base64-encoded provisioning profile |
| `APPLE_TEAM_ID` | iOS | Apple Developer Team ID |
| `IOS_BUNDLE_ID` | iOS | App bundle identifier |
| `APPLE_PROVISIONING_PROFILE_NAME` | iOS | Provisioning profile name |
| `APP_STORE_CONNECT_API_KEY_ID` | iOS | App Store Connect API Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | iOS | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | iOS | Base64-encoded API key (.p8) |

---

## 🤖 Android Setup (Google Play Store)

### Step 1: Create a Signing Keystore

If you don't have a keystore, create one:

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You'll be prompted to enter:
- Keystore password
- Key password
- Your name, organization, city, state, country code

**⚠️ IMPORTANT:** Store this keystore file and passwords securely! You'll need them for every update.

### Step 2: Encode Keystore to Base64

```bash
base64 -i upload-keystore.jks | tr -d '\n' > keystore-base64.txt
```

Copy the contents of `keystore-base64.txt` and add it as `ANDROID_KEYSTORE_BASE64` secret.

### Step 3: Add Keystore Secrets to GitHub

Add these secrets to your repository:
- `ANDROID_KEYSTORE_BASE64`: Content from Step 2
- `ANDROID_KEYSTORE_PASSWORD`: Your keystore password
- `ANDROID_KEY_PASSWORD`: Your key password
- `ANDROID_KEY_ALIAS`: `upload` (or your chosen alias)

### Step 4: Create Google Play Service Account

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to **Settings** → **API access**
3. Click **Create new service account**
4. Follow the link to Google Cloud Console
5. Create a service account with a descriptive name
6. Grant the role **Service Account User**
7. Create a JSON key and download it
8. Back in Play Console, grant the service account **Release manager** permission

### Step 5: Add Service Account JSON to GitHub

Copy the entire JSON content and add it as `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret.

### Step 6: Update Application ID

Update `android/app/build.gradle.kts` with your actual application ID:

```kotlin
defaultConfig {
    applicationId = "com.yourcompany.yourapp"  // Change this!
    ...
}
```

---

## 🍎 iOS Setup (Apple App Store)

### Step 1: Create Distribution Certificate

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, IDs & Profiles**
3. Click **+** to create a new certificate
4. Select **Apple Distribution**
5. Create a Certificate Signing Request (CSR) on your Mac:
   - Open **Keychain Access**
   - Go to **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
   - Enter your email and name, select **Saved to disk**
6. Upload the CSR and download the certificate
7. Double-click to install it in Keychain Access

### Step 2: Export Certificate as P12

1. Open **Keychain Access**
2. Find your **Apple Distribution** certificate
3. Right-click → **Export**
4. Save as `.p12` format
5. Set a strong password

### Step 3: Encode Certificate to Base64

```bash
base64 -i Certificates.p12 | tr -d '\n' > cert-base64.txt
```

Add the contents as `APPLE_CERTIFICATE_P12_BASE64` and the password as `APPLE_CERTIFICATE_PASSWORD`.

### Step 4: Create App Store Provisioning Profile

1. In Apple Developer Portal, go to **Profiles**
2. Click **+** to create new profile
3. Select **App Store** under Distribution
4. Select your app's App ID
5. Select your distribution certificate
6. Name it (e.g., `YourApp App Store`)
7. Download the `.mobileprovision` file

### Step 5: Encode Provisioning Profile to Base64

```bash
base64 -i YourApp_AppStore.mobileprovision | tr -d '\n' > profile-base64.txt
```

Add the contents as `APPLE_PROVISIONING_PROFILE_BASE64`.

### Step 6: Get Apple Team ID

1. Go to Apple Developer Portal
2. Navigate to **Membership** section
3. Copy your **Team ID**

Add as `APPLE_TEAM_ID`.

### Step 7: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Keys**
3. Click **Generate API Key**
4. Name it (e.g., `GitHub Actions`)
5. Grant **App Manager** or **Admin** access
6. Download the `.p8` file (you can only download once!)
7. Note the **Key ID** and **Issuer ID**

### Step 8: Encode API Key to Base64

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | tr -d '\n' > apikey-base64.txt
```

Add these secrets:
- `APP_STORE_CONNECT_API_KEY_ID`: The Key ID from Step 7
- `APP_STORE_CONNECT_API_ISSUER_ID`: The Issuer ID from Step 7
- `APP_STORE_CONNECT_API_KEY_BASE64`: Contents of apikey-base64.txt

### Step 9: Add Remaining iOS Secrets

- `IOS_BUNDLE_ID`: Your app's bundle identifier (e.g., `com.yourcompany.yourapp`)
- `APPLE_PROVISIONING_PROFILE_NAME`: The name you gave the profile in Step 4

### Step 10: Update iOS Bundle Identifier

Make sure your iOS project has the correct bundle identifier in Xcode or `Info.plist`.

---

## 🎯 Triggering Releases

### Option 1: Using Tags (Automatic)

Create and push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This automatically triggers the release workflow for both platforms.

### Option 2: Manual Trigger

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select the workflow (e.g., **Full Release**)
4. Click **Run workflow**
5. Choose options:
   - Android track: `internal`, `alpha`, `beta`, or `production`
   - iOS submit for review: `true` or `false`
6. Click **Run workflow**

### Version Management

Update the version in `pubspec.yaml`:

```yaml
version: 1.0.0+1  # format: version_name+build_number
```

The CI automatically increments the build number using `github.run_number`.

---

## 🔧 Troubleshooting

### Android Issues

**"Keystore was tampered with, or password was incorrect"**
- Verify `ANDROID_KEYSTORE_PASSWORD` is correct
- Re-encode the keystore if needed

**"Could not find service account"**
- Ensure the service account has proper permissions in Play Console
- Verify the JSON is complete and valid

**"Version code already exists"**
- The workflow uses `github.run_number` for build number, which auto-increments
- If issues persist, manually update `version` in `pubspec.yaml`

### iOS Issues

**"No signing certificate found"**
- Verify certificate hasn't expired
- Ensure it's a Distribution certificate, not Development

**"Provisioning profile doesn't match"**
- Profile must match your app's bundle ID
- Profile must include the distribution certificate

**"Invalid credentials for App Store Connect"**
- Verify API Key ID and Issuer ID
- Ensure API key has required permissions
- Check if key has expired or been revoked

### General Tips

1. **Test locally first** - Build release versions on your local machine before relying on CI
2. **Check workflow logs** - GitHub Actions provides detailed logs for debugging
3. **Verify secrets** - Use a simple test workflow to validate secrets are accessible
4. **Keep credentials safe** - Never commit sensitive files to the repository

---

## 📁 Workflow Files

The following workflow files are available:

| File | Description |
|------|-------------|
| `android-release.yml` | Android-only release workflow |
| `ios-release.yml` | iOS-only release workflow |
| `release.yml` | Combined Android + iOS release workflow |

Choose the appropriate workflow based on your needs.

---

## 🔗 Useful Links

- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Google Play Console](https://play.google.com/console)
- [Apple Developer Portal](https://developer.apple.com)
- [App Store Connect](https://appstoreconnect.apple.com)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

