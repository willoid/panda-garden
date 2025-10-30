# Platform Configuration Guide

## Android Configuration

### 1. App Icon
Replace the default Flutter icon with a panda icon:
- Add your panda icon to `android/app/src/main/res/mipmap-*` directories
- Or use the `flutter_launcher_icons` package for automatic generation

### 2. App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Panda Garden"
    ...>
```

### 3. Package Name
To change from default package name:
1. Update `android/app/build.gradle`:
   ```gradle
   applicationId "com.yourcompany.pandagarden"
   ```
2. Update directory structure to match package name

### 4. Minimum SDK Version
In `android/app/build.gradle`:
```gradle
minSdkVersion 21  // or higher for newer features
```

### 5. Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## iOS Configuration

### 1. App Icon
- Use Xcode to add app icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Or use `flutter_launcher_icons` package

### 2. Display Name
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Panda Garden</string>
```

### 3. Bundle Identifier
In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner in the project navigator
3. Change Bundle Identifier to `com.yourcompany.pandagarden`

### 4. Deployment Target
In Xcode or `ios/Podfile`:
```ruby
platform :ios, '12.0'  # or higher
```

### 5. Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSUserNotificationUsageDescription</key>
<string>This app needs notification access to alert the panda about visitor requests</string>
```

## Web Configuration (Optional)

### 1. PWA Icons
Add panda icons to `web/icons/`

### 2. App Name
Edit `web/manifest.json`:
```json
{
    "name": "Panda in the Garden",
    "short_name": "Panda Garden",
    ...
}
```

### 3. HTML Title
Edit `web/index.html`:
```html
<title>Panda in the Garden</title>
```

## Building for Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release
```
Then use Xcode to archive and upload to App Store

### Web
```bash
flutter build web --release
```
Output: `build/web/`

## Signing Apps for Store Release

### Android
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=key
   storeFile=<path-to-key.jks>
   ```

3. Configure `android/app/build.gradle` for signing

### iOS
1. Open project in Xcode
2. Configure signing team
3. Create provisioning profiles
4. Archive and upload to App Store Connect

## Firebase Integration (Optional)

### Android
1. Add `google-services.json` to `android/app/`
2. Add Firebase SDK to `android/build.gradle`
3. Apply plugin in `android/app/build.gradle`

### iOS
1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Add Firebase SDK via CocoaPods
3. Initialize in AppDelegate

## Performance Tips

1. **Enable ProGuard** for Android release builds
2. **Use flutter build with --split-per-abi** for smaller APKs
3. **Optimize images** using WebP format
4. **Enable code obfuscation** for production builds
5. **Remove debug code** and print statements

## Troubleshooting

### Android Build Issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### iOS Build Issues
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter run
```

### Common Issues
- **Gradle version mismatch**: Update in `android/gradle/wrapper/gradle-wrapper.properties`
- **CocoaPods issues**: Run `pod repo update` and `pod install`
- **Xcode signing**: Check provisioning profiles and certificates
