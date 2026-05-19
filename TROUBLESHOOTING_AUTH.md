# Authentication Troubleshooting Guide

## Issue: "Network error: Jwt is not set"

### What This Means
This error occurs when the Flutter app tries to access a protected endpoint (like AI settings or chat) but the user is not authenticated. The backend requires a valid JWT token in the `Authorization` header.

### Root Causes

1. **User not logged in** - The most common cause
   - The app hasn't completed the authentication flow (signup → OTP verification → token received)
   - The auth token wasn't properly saved to local storage
   - The session has expired

2. **Backend `.env` not configured** - JWT_SECRET not set
   - Backend requires `JWT_SECRET` to validate tokens
   - If not set, all endpoints return 401 Unauthorized

3. **API Client not setting auth token** - Token not being passed in request
   - The `ApiClient` stores the token but might not be initialized with it
   - The Authorization header isn't being added to requests

### How to Fix

#### Step 1: Ensure Backend `.env` is Configured

Check your `backend/.env` file has these required variables:

```bash
# JWT Configuration (REQUIRED)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# OTP Configuration (REQUIRED)
OTP_SECRET=your-otp-secret-key-min-32-chars
OTP_EXPIRY_MINUTES=10

# Other required configs...
MONGODB_URI=mongodb://127.0.0.1:27017/ai_travel_planner
GEMINI_API_KEY=your-api-key
```

**Important:** 
- `JWT_SECRET` should be a strong, random string (min 32 characters)
- `OTP_SECRET` should also be a strong, random string
- Never use placeholder values in production

Generate secure secrets:
```bash
# macOS/Linux
openssl rand -base64 32

# PowerShell (Windows)
[System.Convert]::ToBase64String([System.Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes(24))
```

#### Step 2: Verify Backend is Running

```bash
cd backend
npm run dev
```

Check the logs show:
```
Server listening on http://0.0.0.0:5000
```

Test health endpoint:
```bash
curl http://localhost:5000/api/health
# Should return: {"status":"ok","message":"Backend is running"}
```

#### Step 3: Complete Authentication Flow in Flutter App

1. **Open the app** and go to Auth screen
2. **Sign up or Sign in** with your email
3. **Wait for OTP email** (check spam folder if using Gmail)
4. **Enter OTP** in the app
5. **Verify OTP** - This returns the JWT token
6. **You're logged in!** - Token is saved to `SharedPreferences`

#### Step 4: Only After Login - Access AI Features

Once logged in, you can:
- Navigate to Dashboard
- Open "AI Settings" from menu
- Open "AI Chat" from menu

**If you see "Please log in first":**
- Go back to login screen
- Complete the authentication flow again

### Common Scenarios

#### Scenario 1: Trying to Access AI Settings Before Login
```
Error: "Please log in first" or "Authentication required"
Fix: Complete the auth flow (signup/signin/verify OTP)
```

#### Scenario 2: Token Expired
```
Error: "Session expired. Please log in again."
Fix: Go back to Auth screen and log in again
```

#### Scenario 3: Backend Not Running
```
Error: Network error or connection refused
Fix: 
1. Run: cd backend && npm run dev
2. Verify port 5000 is accessible
3. Check firewall settings
```

#### Scenario 4: Wrong Backend URL
```
Error: Network errors when trying to connect
Fix:
1. Open: frontend/lib/services/api_client.dart
2. Check baseUrl:
   - Local: 'http://localhost:5000/api'
   - Emulator: 'http://10.0.2.2:5000/api'
   - Remote: 'http://your-ip:5000/api'
3. Ensure backend is accessible at that URL
```

#### Scenario 5: DISABLE_AUTH_FOR_LOCAL for Testing

For **local development only**, you can bypass authentication:

**In `backend/.env`:**
```
DISABLE_AUTH_FOR_LOCAL=true
LOCAL_TEST_USER_ID=67e000000000000000000001
LOCAL_TEST_USER_EMAIL=local@test.com
```

**Then restart backend:**
```bash
npm run dev
```

Now you can access endpoints without login. **NEVER enable this in production!**

### Debug Checklist

- [ ] Backend `.env` has `JWT_SECRET` and `OTP_SECRET` set
- [ ] Backend is running (`npm run dev`)
- [ ] Backend health check works: `curl http://localhost:5000/api/health`
- [ ] User completed signup → OTP → verification
- [ ] Auth token is saved locally (check `SharedPreferences` in Flutter)
- [ ] `ApiClient.baseUrl` points to correct backend URL
- [ ] Try logging in again
- [ ] Check browser DevTools / adb logcat for actual error message
- [ ] Restart both backend and Flutter app

### Getting the Actual Error Message

To see the real error from the backend:

**Option 1: Check backend logs**
```bash
# Backend console output shows actual errors
npm run dev
# Look for [API ERROR] messages
```

**Option 2: Use curl to test endpoint**
```bash
# Try without token (should fail)
curl http://localhost:5000/api/users/ai-settings

# Try with fake token (should fail)
curl -H "Authorization: Bearer fake-token" \
     http://localhost:5000/api/users/ai-settings

# Try with valid token (should work)
curl -H "Authorization: Bearer <your-actual-token>" \
     http://localhost:5000/api/users/ai-settings
```

**Option 3: Check Flutter logs**
```bash
# Run with detailed logging
flutter run -v

# Look for network error messages and HTTP status codes
```

### Still Having Issues?

1. **Clear cache & restart**
   ```bash
   # Flutter
   flutter clean
   flutter pub get
   flutter run
   
   # Backend
   npm run dev
   ```

2. **Check MongoDB connection**
   ```bash
   # Verify MongoDB is running
   mongosh
   # Should connect successfully
   ```

3. **Verify network connectivity**
   ```bash
   # Test backend accessibility
   ping localhost  # or your backend IP
   curl http://localhost:5000/api/health
   ```

4. **Check user exists in database**
   ```bash
   # Connect to MongoDB
   mongosh mongodb://127.0.0.1:27017/ai_travel_planner
   
   # List users
   db.users.find({})
   
   # Find specific user
   db.users.findOne({ email: 'your@email.com' })
   ```

### Next Steps

- After successful login, see [GEMINI_INTEGRATION_GUIDE.md](GEMINI_INTEGRATION_GUIDE.md) for AI features
- To deploy to production, refer to the deployment section in the integration guide
- For detailed API reference, see [GEMINI_INTEGRATION_GUIDE.md](GEMINI_INTEGRATION_GUIDE.md#api-endpoints-reference)

---

**Need more help?**  
Check the backend console output for detailed error messages when you get a network error.
