# Quick Reference Guide - Travel Planner Flutter App

## 📱 What is This?

A complete Flutter frontend for the Travel Planner app that helps users generate AI-powered travel itineraries using their backend API.

## 🚀 Quick Start (2 minutes)

```bash
# 1. Install dependencies
cd frontend
flutter pub get

# 2. Update backend URL (if not localhost)
# Edit: lib/services/api_client.dart (line 9)
# Change: static const String baseUrl = 'your-backend-url:5000/api';

# 3. Run the app
flutter run
```

## 🎯 Main Features at a Glance

| Feature | Location | Description |
|---------|----------|-------------|
| **Sign Up** | AuthScreen | Create account with email + OTP |
| **Sign In** | AuthScreen | Login with email + OTP |
| **Generate Trip** | RecipeGenerationScreen | Create AI itinerary with details |
| **View Trip** | RecipeDetailScreen | See day-by-day breakdown |
| **Preferences** | PreferencesScreen | Save travel style, budget, diet |
| **Dashboard** | DashboardScreen | View all your trips |

## 📁 Important Files

```
lib/
├── main.dart                    ← Start here (app setup)
├── services/api_client.dart     ← Update backend URL here
├── providers/                   ← State management
├── screens/                     ← All UI screens
└── models/                      ← Data structures
```

## 🔑 Key Concepts

### Providers (State Management)
- **AuthProvider**: Handles login/logout/token storage
- **RecipeProvider**: Manages itineraries
- **UserProvider**: Manages user preferences

### Screens (User Interface)
- **AuthScreen**: Login/signup toggle
- **OTPScreen**: Email verification (6 digits)
- **DashboardScreen**: Home page with trips list
- **RecipeGenerationScreen**: Create new trip
- **RecipeDetailScreen**: View trip details
- **PreferencesScreen**: User settings

### Services (Backend Communication)
- **ApiClient**: All API calls to backend

## 📱 User Journey

```
1. Start App (no login) → AuthScreen
   ↓
2. Sign Up or Sign In → OTPScreen
   ↓
3. Enter OTP → DashboardScreen (home)
   ↓
4. User can:
   - Click "Generate New Itinerary" → RecipeGenerationScreen
   - Click existing trip → RecipeDetailScreen
   - Click menu → PreferencesScreen
   - Click menu → Logout
```

## 🔧 Configuration

### Update Backend URL
**File**: `lib/services/api_client.dart` (line 9)

```dart
// Default (localhost with backend on same machine)
static const String baseUrl = 'http://localhost:5000/api';

// For Android emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For remote server
static const String baseUrl = 'https://your-server.com/api';
```

## 🧪 Testing the App

### Test Signup
1. Tap "Sign Up"
2. Enter name: "John Doe"
3. Enter email: "john@example.com"
4. Tap "Sign Up"
5. Check backend console for OTP
6. Enter 6 digits
7. Should see Dashboard

### Test Trip Generation
1. From Dashboard, tap "Generate New Itinerary"
2. Enter:
   - From: "New York"
   - To: "Paris"
   - Days: 5
   - Budget: "Moderate"
3. Tap "Generate Itinerary"
4. Wait 30-60 seconds for AI
5. View generated trip with day-wise details

### Test Preferences
1. From Dashboard, tap menu (three dots)
2. Tap "Preferences"
3. Select options and tap "Save"
4. Should see success message

## 🐛 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| "Connection refused" | Check backend URL in api_client.dart |
| "OTP not received" | Check backend console (dev mode logs OTP) |
| "Can't connect on Android" | Use `10.0.2.2` instead of `localhost` |
| "Flash/reload not working" | Run `flutter clean && flutter pub get` |
| "Layout issues" | Check phone rotation settings |

## 💡 Pro Tips

1. **For Android emulator**: Use `10.0.2.2:5000` for localhost
2. **OTP in dev**: Backend console shows OTP (check terminal)
3. **Token expires**: Logout and login again (backend sets 7 days default)
4. **Slow generation**: AI itineraries can take 30-120 seconds
5. **Data persistence**: Token saved automatically, trips fetched on dashboard

## 📊 App Architecture in 30 Seconds

```
UI Screens (display)
        ↓
Providers (manage state)
        ↓
ApiClient (talk to backend)
        ↓
Backend Server
```

## 🎨 UI Colors

- **Primary**: Blue (all main buttons)
- **Success**: Green (checkmarks, success messages)
- **Warning**: Orange (info, tips)
- **Error**: Red (errors, warnings)
- **Neutral**: Gray (secondary text, borders)

## 📋 API Endpoints Used

All endpoints integrated:

```
Auth:
- POST /api/auth/signup
- POST /api/auth/signin
- POST /api/auth/verify-otp

User:
- GET  /api/users/me
- PUT  /api/users/preferences

Recipes:
- POST /api/recipes/generate
- GET  /api/recipes

Dashboard:
- GET  /api/dashboard

Health:
- GET  /api/health
```

## ⚙️ Building for Production

### Android Release Build
```bash
flutter build apk --release
# Install at: build/app/release/app-release.apk
```

### iOS Release Build
```bash
flutter build ios --release
# Build at: build/ios/iphoneos/Runner.app
```

### Web Release Build
```bash
flutter build web --release
# Deploy: build/web/ folder to server
```

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| FRONTEND_ARCHITECTURE.md | Complete architecture overview |
| SETUP_INSTRUCTIONS.md | Detailed setup guide |
| SCREENS_GUIDE.md | Screen-by-screen walkthrough |
| FRONTEND_IMPLEMENTATION_SUMMARY.md | Project summary |

## 🆘 Need Help?

1. Check **SETUP_INSTRUCTIONS.md** for detailed setup
2. Check **SCREENS_GUIDE.md** for feature details
3. Check **FRONTEND_ARCHITECTURE.md** for code structure
4. Look at error messages in console
5. Verify backend is running: `curl http://localhost:5000/api/health`

## 📦 What's Included

✅ 6 complete screens
✅ 3 state management providers
✅ Complete API client
✅ 5 data models
✅ Material Design 3 UI
✅ Form validation
✅ Error handling
✅ Loading states
✅ Responsive layout
✅ Full documentation

## 🎉 You're Ready!

The frontend is complete and production-ready. Just:
1. Set backend URL
2. Run `flutter pub get`
3. Run `flutter run`
4. Test the flow

**Enjoy your Travel Planner app!** ✈️

---

## Quick Command Reference

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Debug
flutter run -v

# Build APK
flutter build apk --release

# Clean project
flutter clean

# Check issues
flutter analyze

# Update packages
flutter pub upgrade
```

## File Locations Quick Map

| What | File |
|------|------|
| Change Backend URL | `lib/services/api_client.dart` line 9 |
| Modify Screens | `lib/screens/` |
| Change State Logic | `lib/providers/` |
| Update Models | `lib/models/` |
| Control Auth Flow | `lib/main.dart` |
| Add Dependencies | `pubspec.yaml` |

---

**Happy coding! The frontend is ready to use!** 🚀
