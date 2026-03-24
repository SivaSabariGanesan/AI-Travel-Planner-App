# Screen-by-Screen Guide

A comprehensive walkthrough of all screens in the Travel Planner Flutter app with features and usage instructions.

## 🔐 Authentication Screens

### Auth Screen (`lib/screens/auth_screen.dart`)

**Purpose**: Handle user login and signup

**Features**:
- Toggle between Sign Up and Sign In modes
- Email validation using email_validator
- Name field for signup mode
- Form validation before submission
- Loading indicator during submission
- Error message display
- Switch between signup/signin with form reset

**UI Components**:
- Travel icon header
- Form fields with prefixes
- Rounded submit button
- Error container (red background)
- Sign up/Sign in toggle link

**User Actions**:
1. Click "Sign Up" tab
2. Enter name and email
3. Click "Sign Up" button
4. On success → Navigate to OTP Screen
5. On error → Show error message

**Validation**:
- Email: Must be valid email format
- Name (signup only): Must not be empty

**API Connection**:
- `POST /api/auth/signup` - For signup
- `POST /api/auth/signin` - For signin

---

### OTP Screen (`lib/screens/otp_screen.dart`)

**Purpose**: Verify email with 6-digit OTP

**Features**:
- 6 separate input fields (one digit each)
- Auto-focus navigation between fields
- 5-minute countdown timer
- Visual timer warning (red when < 60 seconds)
- Automatic resend option when expired
- Loading indicator during verification
- Error message display
- Back button to try different email

**UI Components**:
- Mail icon header
- 6 OTP input fields in a row
- Countdown timer display
- Verify button
- Resend link (appears when expired)
- Email display for confirmation

**User Actions**:
1. Enter each OTP digit
2. Auto-moves focus after digit entry
3. Click "Verify OTP" button
4. On success → Dashboard
5. On error → Show error message
6. If expired → Click "Request new OTP"

**Auto-Features**:
- Auto-focus navigation
- Auto-unfocus after complete entry
- Auto-move back when deleting
- Next field focus on digit entry

**Timer**:
- Starts at 5 minutes (300 seconds)
- Counts down every second
- Disables verify button at 0
- Shows formatted MM:SS

**API Connection**:
- `POST /api/auth/verify-otp` - Verify OTP and get JWT token

---

## 🏠 Main App Screens

### Dashboard Screen (`lib/screens/dashboard_screen.dart`)

**Purpose**: Main home screen showing user overview and recent itineraries

**Features**:
- Welcome header with user name and gradient background
- Quick action button to generate new itinerary
- List of recent itineraries
- User menu with settings and logout
- Empty state when no itineraries
- Pull-to-refresh functionality (via scroll)

**UI Components**:
- Gradient header with travel icon
- User name in large text
- "Generate New Itinerary" button (blue, rounded)
- "Recent Itineraries" section title
- Recipe cards with metadata
- Menu button (top right) with popup

**Recipe Card Shows**:
- Trip topic
- From location → To destination
- Created date
- Number of days (if available)
- Click to view full itinerary

**User Menu Options**:
1. **Preferences** - Navigate to preferences screen
2. **Logout** - Sign out and return to auth screen

**User Actions**:
1. View recent trips
2. Click trip card to view details
3. Click "Generate New Itinerary" to create new trip
4. Click menu for preferences or logout

**Loading States**:
- Circular progress indicator when loading recipes
- Empty state message when no recipes
- Menu button disabled during logout

**API Connections**:
- `GET /api/recipes` - Fetch all recipes
- Automatic on screen init

---

### Recipe Generation Screen (`lib/screens/recipe_generation_screen.dart`)

**Purpose**: Create a new AI-powered itinerary

**Features**:
- Multi-section form with validation
- Date picker for start/end dates
- Chip-based budget selection
- Counter for number of travelers
- Multi-select for interests and notes
- Form submission with 2-minute timeout
- Loading indicator during generation
- Success and error messages

**Form Sections** (In order):

1. **Trip Topic (Optional)**
   - Text input
   - Hint: "e.g., Summer Vacation, Honeymoon"

2. **Starting Location (Required)**
   - Text input with location icon
   - Validation: Must not be empty

3. **Destination (Required)**
   - Text input with location icon
   - Validation: Must not be empty

4. **Trip Dates (Optional)**
   - Two date picker buttons (Start & End)
   - Shows selected dates or placeholder
   - Range from today to +365 days

5. **Budget (Optional)**
   - Choice chips: Budget, Moderate, Luxury, Custom
   - Single select only

6. **Number of Travelers**
   - Increment/Decrement buttons
   - Range: 1-10
   - Default: 1

7. **Interests (Optional)**
   - Filter chips (multi-select)
   - Options: Adventure, Culture, Food, Nature, Beach, Historical, Art, Photography, Nightlife, Shopping

8. **Additional Notes (Optional)**
   - Multi-line text input (max 3 lines)

**UI Components**:
- AppBar with title "Plan Your Trip"
- Organized section titles (gray text)
- Form fields with borders and icons
- Choice/Filter chips for selections
- Increment/decrement buttons for counter
- Large blue submit button
- Loading spinner during submission

**Validation**:
- From location: Required
- To location: Required
- All other fields: Optional

**User Actions**:
1. Fill in required fields (from & to location)
2. Optionally set dates, budget, interests
3. Click "Generate Itinerary"
4. Wait for AI generation (30-120 seconds)
5. View generated itinerary

**Loading**:
- Button shows spinner during generation
- Button disabled while generating
- Can navigate back anytime

**API Connection**:
- `POST /api/recipes/generate` - Generate new itinerary
- 2-minute timeout for long generations

**Success Flow**:
- Show toast "Itinerary generated successfully!"
- Pop current screen
- Navigate to Recipe Detail Screen

---

### Recipe Detail Screen (`lib/screens/recipe_detail_screen.dart`)

**Purpose**: Display complete itinerary with day-wise breakdown

**Features**:
- Pinned header with from → to location
- Expandable day-wise itinerary cards
- Local food recommendations
- Packing checklist
- Transport tips
- Budget estimation
- Scrollable layout with proper spacing

**Header Section**:
- Large icon with gradient background
- From location → To destination (bold)
- Expandable with landscape trip info

**Trip Information Boxes**:
- Days (if available)
- Number of travelers
- Budget (if available)
- Color-coded boxes (blue, orange, green)

**Overview Section** (if available):
- Title (large, bold)
- Summary text (gray background box)
- Interests as chips

**Day-wise Itinerary**:
- Expandable cards per day
- Shows day name/number
- Shows plan preview (one line, truncated)
- Click to expand and see:
  - Full plan description
  - Activities (with bullet points)
  - Meals (with restaurant icon)

**Local Food Ideas Section**:
- List of food items
- Restaurant icon prefix
- Scrollable list

**Packing Checklist Section**:
- Checklist items
- Check circle icon prefix
- Easy to scan

**Transport Tips Section**:
- Cyan background box
- Full text explanation
- Helpful travel tips

**UI Components**:
- Collapsible SliverAppBar with gradient
- Cards with expansion animation
- Color-coded sections
- Icon indicators for different content types
- Smooth scrolling (SliverScrollView)

**User Actions**:
1. View overview and trip info
2. Tap day card to expand/collapse
3. Read activities and meals for each day
4. Check food ideas and packing list
5. Read transport tips
6. Scroll through entire itinerary

**Expandable Feature**:
- Tap day card header to toggle expansion
- Only one day expanded at a time
- Smooth animation on expand/collapse
- Full content visible when expanded

**Styling**:
- Day header: Bold title with expand icon
- Activities: Bullet points in smaller text
- Meals: Restaurant-themed display
- Consistent indentation and spacing

---

### Preferences Screen (`lib/screens/preferences_screen.dart`)

**Purpose**: Manage user travel preferences

**Features**:
- Multiple preference categories
- Chip-based selections (both choice and filter)
- Persistent storage to backend
- Loading indicator during save
- Error message display
- Save button with loading state

**Preference Sections**:

1. **Travel Style** (Single select)
   - Options: Adventure, Relaxation, Cultural, Food, Beach, Mountain, Urban
   - Blue chips

2. **Budget** (Single select)
   - Options: Budget, Moderate, Luxury
   - Blue chips

3. **Trip Pace** (Single select)
   - Options: Slow, Moderate, Fast
   - Blue chips

4. **Food Preferences** (Multi-select)
   - Options: Vegetarian, Vegan, Non-Vegetarian, Seafood, Local Cuisine, International
   - Filter chips (toggleable)

5. **Dietary Restrictions** (Multi-select)
   - Options: Gluten-free, Dairy-free, Nut-free, Low-sodium, Low-sugar
   - Filter chips (toggleable)

6. **Preferred Destinations** (Multi-select)
   - Options: Mountains, Beaches, Cities, Countryside, Deserts, Forests, Islands
   - Filter chips (toggleable)

**UI Components**:
- AppBar with "Travel Preferences" title
- Section titles (all caps, bold)
- Choice chips (blue outline, filled when selected)
- Filter chips (outline only, filled when selected)
- "Save Preferences" button (blue, rounded)
- Error container (red background)
- Loading spinner on button during save

**Chip Types**:
- **ChoiceChip**: For single-select preferences (Travel Style, Budget, Pace)
- **FilterChip**: For multi-select preferences (Food, Dietary, Destinations)

**User Actions**:
1. Select one option per single-select section
2. Select multiple options for multi-select sections
3. Click "Save Preferences" button
4. Wait for save (loading spinner)
5. See success message (toast) and pop screen

**API Connection**:
- `PUT /api/users/preferences` - Save preferences to backend

**Success Message**:
- Toast: "Preferences saved!"
- Auto-dismiss after 2 seconds
- Navigate back to previous screen

**Error Handling**:
- Show error message in red box
- Allow user to retry saving
- Error message displayed below button

---

## 🔄 Navigation Flow

```
┌─────────────────┐
│   Auth Screen   │
│  (Login/Signup) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   OTP Screen    │
│  (Verify Email) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Dashboard Screen       │
│  (Main App Home)        │
└───┬──────────────────┬──┘
    │                  │
    ▼                  ▼
┌──────────────┐  ┌──────────────┐
│Recipe Detail │  │Preferences   │
│Screen        │  │Screen        │
└──────────────┘  └──────────────┘
    ▲
    │
    ▼
┌──────────────────────┐
│Recipe Generation     │
│Screen                │
└──────────────────────┘
```

## 📱 Responsive Design

All screens are designed to work on:
- Phone (320-600dp width)
- Tablet (600dp+ width)
- Landscape orientation
- Different text scaling settings

---

## 💡 Tips for Users

1. **Signup**: Use real email to receive OTP in backend console
2. **Generation**: Longer itineraries (5+ days) take longer to generate
3. **Preferences**: Save often as they improve itinerary recommendations
4. **Offline**: Screenshots itinerary details if needed for offline reference
5. **Budget**: Choose appropriate budget level for better recommendations

---

## 🎨 Design Consistency

All screens follow:
- Material Design 3 guidelines
- Blue color scheme for primary actions
- Consistent spacing (8px unit grid)
- Rounded corners (12px default)
- Clear hierarchy with typography
- Proper touch target sizes (48dp minimum)
- Consistent error and success messaging

---

## ⚠️ Error States

All screens handle:
- Network timeouts → "Network error"
- 401 Unauthorized → Logout and return to auth
- Validation errors → Inline validation messages
- API errors → Display error message and retry option
- Loading states → Disable buttons and show spinner

---

**Each screen is fully functional and integrated with the backend API!**
