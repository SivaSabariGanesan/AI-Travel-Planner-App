# Travel Planner Flutter Frontend

A beautiful, feature-rich Flutter application for planning AI-powered travel itineraries.

## 🏗️ Architecture

### Folder Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── user_model.dart               # User and UserPreferences models
│   └── recipe_model.dart             # Recipe and related models
├── services/
│   └── api_client.dart               # HTTP client for backend communication
├── providers/
│   ├── auth_provider.dart            # Authentication state management
│   ├── recipe_provider.dart          # Recipe/Itinerary state management
│   └── user_provider.dart            # User preferences state management
└── screens/
    ├── auth_screen.dart              # Login/Signup screen
    ├── otp_screen.dart               # OTP verification screen
    ├── dashboard_screen.dart         # Main dashboard with itineraries
    ├── recipe_generation_screen.dart # Form to generate new itineraries
    ├── recipe_detail_screen.dart     # Detailed itinerary view
    └── preferences_screen.dart       # User preferences/settings
```

## 📦 Dependencies

### Key Packages
- **provider**: State management
- **http**: HTTP client for API calls
- **shared_preferences**: Local storage for auth tokens
- **intl**: Date/time formatting
- **email_validator**: Email validation
- **google_fonts**: Better typography
- **lottie**: Animations (optional, can be added for animations)

## 🔄 State Management

The app uses **Provider** for state management with three main providers:

### AuthProvider
Handles user authentication flow:
- Signup with email
- Sign in with email
- OTP verification
- Token storage and persistence
- Logout

### RecipeProvider
Manages travel itineraries:
- Generate new recipes/itineraries
- Fetch all recipes
- Select recipe for viewing
- Loading and error states

### UserProvider
Manages user profile and preferences:
- User data
- Travel preferences (style, budget, dietary restrictions, etc.)
- Update preferences

## 📱 Screens

### Authentication Flow
1. **AuthScreen**: Login/Signup
   - Toggle between signup and signin modes
   - Email and name (for signup) input
   - Form validation

2. **OTPScreen**: OTP Verification
   - 6-digit OTP input fields
   - Auto-focus navigation between fields
   - 5-minute countdown timer
   - Resend option when expired

### Main App
3. **DashboardScreen**: Home/Dashboard
   - Welcome header with user name
   - Quick access to generate itinerary
   - List of recent itineraries
   - User menu (settings, logout)

4. **RecipeGenerationScreen**: Create Itinerary
   - Trip topic/name
   - Starting location and destination
   - Date range selection
   - Budget selection
   - Number of travelers
   - Interests selection
   - Additional notes

5. **RecipeDetailScreen**: View Itinerary
   - Trip overview and summary
   - Day-wise breakdown (expandable)
   - Local food ideas
   - Packing checklist
   - Transport tips
   - Budget estimation

6. **PreferencesScreen**: User Settings
   - Travel style preferences
   - Budget preference
   - Trip pace
   - Food preferences
   - Dietary restrictions
   - Preferred destinations

## 🌐 API Integration

### ApiClient Features
- Base URL configuration (update in `api_client.dart`)
- Automatic JWT token management
- Error handling with custom `ApiException`
- Authentication header injection
- Network timeout handling

### Endpoints Integrated
```
POST   /api/auth/signup              - Create new user account
POST   /api/auth/signin              - Initiate signin
POST   /api/auth/verify-otp          - Verify OTP and get token
GET    /api/users/me                 - Get current user info
PUT    /api/users/preferences        - Update preferences
GET    /api/dashboard                - Get dashboard data
POST   /api/recipes/generate         - Generate itinerary
GET    /api/recipes                  - Get all itineraries
GET    /api/health                   - Health check
```

## 🔐 Authentication

- **Type**: JWT with Email OTP
- **Token Storage**: SharedPreferences
- **Auto-Persistence**: Tokens are automatically loaded on app restart
- **Unauthorized Handling**: 401 responses trigger logout

## 🎨 Design System

- **Color Scheme**: Blue-based Material Design 3
- **Typography**: Google Fonts (Inter)
- **Component Styling**: 
  - Rounded corners (12px default)
  - Shadow effects for cards
  - Gradient backgrounds for headers
  - Consistent spacing (8px grid)

## 🚀 Getting Started

### Prerequisites
- Flutter 3.11.3 or higher
- Dart 3.0 or higher
- Backend server running on `http://localhost:5000`

### Installation

1. **Install dependencies**:
```bash
cd frontend
flutter pub get
```

2. **Configure API URL** (if different from localhost):
   - Edit [lib/services/api_client.dart](lib/services/api_client.dart#L9)
   - Change `baseUrl` to your backend URL

3. **Run the app**:
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

## 📝 Key Features

- ✅ Email-based OTP authentication
- ✅ Persistent login with token storage
- ✅ User preference management
- ✅ AI-powered itinerary generation
- ✅ Detailed trip planning with day-wise breakdown
- ✅ Food and dietary preference filtering
- ✅ Budget estimation
- ✅ Packing checklist
- ✅ Transport tips
- ✅ Beautiful Material Design 3 UI
- ✅ Responsive design for multiple screen sizes

## 🔧 Configuration

### Update Backend URL
Edit [lib/services/api_client.dart](lib/services/api_client.dart#L9):
```dart
static const String baseUrl = 'http://your-backend-url:5000/api';
```

### Environment Variables (if using .env)
You can enhance the app by adding flutter_dotenv support:
1. Create `.env` file at root
2. Add `BACKEND_URL=your-url`
3. Load using `dotenv.load()`

## 🐛 Troubleshooting

### Connection Issues
- Verify backend URL in `api_client.dart`
- Check if backend is running
- On Android emulator, use `10.0.2.2` instead of `localhost`

### OTP Not Received
- Check backend email configuration
- On development, OTP is logged to backend console

### Token Expiry
- Token expires based on backend JWT_EXPIRES_IN config (default 7 days)
- App handles 401 responses by showing auth screen

### State Issues
- Clear app cache: `flutter clean && flutter pub get`
- Restart the app with hot restart (not just hot reload)

## 📊 Data Models

### User Model
- id, name, email
- isVerified: boolean
- preferences: UserPreferences
- createdAt, updatedAt, lastLoginAt: DateTime

### UserPreferences Model
- travelStyle, budget, tripPace: String
- foodChoices, dietaryRestrictions, preferredDestinations: List<String>

### Recipe Model
- id, userId, topic
- itineraryInput: RecipeInput (from/to location, dates, travelers, etc.)
- generatedContent: GeneratedContent
  - title, summary, route, duration
  - interests: List<String>
  - dayWisePlan: List<DayWisePlan>
  - localFoodIdeas, packingChecklist: List<String>
  - transportTips, estimatedBudget: String

## 🚧 Future Enhancements

- [ ] Offline support with local database
- [ ] Share itineraries with others
- [ ] Save/favorite itineraries
- [ ] Push notifications for travel reminders
- [ ] Integration with booking services
- [ ] Photo gallery of destinations
- [ ] Map integration
- [ ] Voice-based itinerary generation
- [ ] Multi-language support
- [ ] Dark mode theme

## 📄 License

This project is part of the Travel Planner application.

## 👤 Getting Help

For issues or questions:
1. Check the troubleshooting section
2. Review the code comments for implementation details
3. Check backend API documentation
4. Verify network connectivity and API server status
