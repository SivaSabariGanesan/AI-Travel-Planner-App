# Flutter Frontend Setup Instructions

## Quick Start Guide

### Step 1: Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

### Step 2: Update Backend API URL

Open `lib/services/api_client.dart` and update the `baseUrl`:

```dart
static const String baseUrl = 'http://localhost:5000/api';
// or your actual backend URL
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

For Android emulator to reach localhost:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

### Step 3: Run the App

**Development (Hot Reload)**:
```bash
flutter run
```

**Release Build**:
```bash
flutter run --release
```

## Platform-Specific Setup

### Android

**Minimum Requirements**:
- Android SDK 21 (Android 5.0)
- Android Studio or command-line tools

**Run on Emulator**:
```bash
flutter run -d emulator
```

**Run on Physical Device**:
1. Enable USB Debugging on device
2. Connect via USB
3. Run: `flutter devices` to verify
4. Run: `flutter run`

**Build APK**:
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# APK with optimizations
flutter build apk --split-per-abi --release
```

### iOS

**Minimum Requirements**:
- macOS with Xcode 14+
- iOS 11.0 or higher

**Setup**:
```bash
cd ios
pod install
cd ..
```

**Run**:
```bash
flutter run
```

**Build**:
```bash
flutter build ios --release
```

### Web

**Run**:
```bash
flutter run -d chrome
```

**Build**:
```bash
flutter build web --release
```

### Windows

**Build**:
```bash
flutter build windows
```

### macOS

**Build**:
```bash
flutter build macos
```

## Environment Configuration

### Option 1: Direct URL Editing (Simple)

Edit `lib/services/api_client.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.com/api';
```

### Option 2: Environment Variables (Production)

1. Create `.env` file in project root:
```
BACKEND_URL=https://your-backend-url.com/api
```

2. Install flutter_dotenv (already in pubspec.yaml if needed):
```bash
flutter pub add flutter_dotenv
```

3. Load in main.dart:
```dart
void main() async {
  await dotenv.load();
  runApp(const MyApp());
}
```

4. Use in api_client.dart:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static String baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000/api';
  // ...
}
```

## Testing the App

### Test Authentication Flow
1. Open app → Sign Up screen
2. Enter test email and name
3. Check backend console for OTP (dev mode shows it)
4. Enter OTP
5. Should navigate to Dashboard

### Test Itinerary Generation
1. Click "Generate New Itinerary" button
2. Fill in:
   - Starting location: "New York"
   - Destination: "Paris"
   - Days: 5
   - Budget: "Moderate"
3. Click "Generate Itinerary"
4. Wait for AI to generate (may take 30-60 seconds)
5. View generated itinerary

### Test Preferences
1. Click menu icon → Preferences
2. Select travel style, budget, dietary preferences
3. Click "Save Preferences"
4. Verify success message

## Common Issues & Solutions

### Issue: "Connection refused"
**Solution**: 
- Verify backend is running: `http://localhost:5000/api/health`
- Check firewall settings
- Use correct URL (10.0.2.2 for Android emulator)

### Issue: "No visible characters for locale"
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Permission denied" (Android)
**Solution**: Grant permissions in `android/app/src/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Issue: "Keystore not found" (Building APK)
**Solution**: Create debug keystore:
```bash
keytool -genkey -v -keystore ~/debug.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias androiddebugkey
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

## Debug Mode

### Enable Debug Logging

Add to main.dart:
```dart
void main() {
  // Enable HTTP logging
  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  // Print debug info
  debugPrint('API Base URL: ${ApiClient.baseUrl}');
  
  runApp(const MyApp());
}
```

### Monitor Network Requests

Android Studio / VS Code:
- Use Dev Tools: `flutter devtools`
- Network tab shows all HTTP requests
- Check request/response bodies

### Dart Debug Console

```bash
flutter run -v  # Verbose logging
```

## Performance Optimization

### Release Build for Testing
```bash
flutter run --release
```

### Remove Unused Dependencies
```bash
flutter pub clean
flutter analyze
```

### Build Size Optimization
```bash
flutter build apk --split-per-abi --release
flutter build ios --release
```

## Deployment

### Play Store (Android)
1. Create signed APK/AAB
2. Set version in pubspec.yaml
3. Upload to Google Play Console
4. Follow their review process

### App Store (iOS)
1. Create release build
2. Sign with certificate
3. Upload via Xcode or transporter
4. Follow Apple review guidelines

### Web Hosting
```bash
flutter build web --release
# Deploy 'build/web' folder to web server
```

## Package Management

### Update Dependencies
```bash
flutter pub upgrade
```

### Update Specific Package
```bash
flutter pub upgrade package_name
```

### Check for Issues
```bash
flutter pub outdated
```

## Tips & Best Practices

1. **Always test on physical devices** before release
2. **Use release builds** for performance testing
3. **Check console logs** for errors and warnings
4. **Verify API connectivity** before reporting bugs
5. **Keep pubspec.yaml updated** regularly
6. **Use proper error handling** in production
7. **Test with different screen sizes** (tablets, phones)
8. **Enable ProGuard** for Android release builds

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)
- [Material Design](https://material.io)

## Support

For issues:
1. Check the FRONTEND_ARCHITECTURE.md
2. Review error messages in console
3. Check backend logs for API errors
4. Verify network connectivity
5. Try `flutter clean` and rebuild

---

**Happy Coding!** 🚀
