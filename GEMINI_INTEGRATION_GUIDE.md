# Gemini AI Integration - Complete Setup & Deployment Guide

## Overview

This project integrates Google Gemini API with two access modes:
1. **App AI Mode** - Uses company/developer Gemini API key (backend-only)
2. **BYOK Mode** - Users can bring their own Gemini API key (validated, encrypted, stored)

The architecture ensures API keys are never exposed to the Flutter frontend and all Gemini API calls route through the Express backend.

---

## Architecture

```
Flutter App
    ↓
API Client (secure HTTP)
    ↓
Express Backend + Rate Limiter
    ↓
Gemini Service (API key resolution)
    ↓
Google Gemini API
```

### Key Features
- ✅ Dual API key support (company + user)
- ✅ AES-256-GCM encryption for stored user keys
- ✅ Request rate limiting (configurable)
- ✅ Usage tracking per user
- ✅ Streaming response support
- ✅ Retry logic for failed requests
- ✅ Structured JSON responses
- ✅ Error handling & graceful degradation

---

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

All required packages are in `package.json`:
- `@google/generative-ai` - Gemini SDK
- `express-rate-limit` - Rate limiting
- `mongodb` & `mongoose` - Database
- Other supporting packages

### 2. Environment Configuration

Create `.env` file in `backend/` directory (use `.env.example` as template):

```bash
# Copy the example
cp .env.example .env

# Edit .env and fill in values
```

**Required environment variables:**

| Variable | Value | Notes |
|----------|-------|-------|
| `PORT` | `5000` | Backend server port |
| `MONGODB_URI` | `mongodb://localhost:27017/travelplanner` | MongoDB connection string |
| `GEMINI_API_KEY` | Your company Gemini API key | **KEEP SECRET** - never commit |
| `GEMINI_MODEL` | `gemini-1.5-flash` | Gemini model name (optional) |
| `GEMINI_KEY_ENCRYPTION_SECRET` | 32+ character secret | Used to encrypt user Gemini keys |
| `AI_RATE_LIMIT_WINDOW_MS` | `60000` | Rate limit window (ms) - optional |
| `AI_RATE_LIMIT_MAX` | `20` | Max requests per window - optional |

**Getting Gemini API Key:**
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy and paste into `.env`

**Encryption Secret:**
- Generate: `openssl rand -base64 24` or use a 32+ character random string
- Example: `your-super-secret-encryption-key-min-24-chars`

### 3. Start Backend Server

```bash
npm run dev
```

Expected output:
```
Server listening on http://0.0.0.0:5000
```

Verify health endpoint:
```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "Backend is running"
}
```

### 4. Verify Database Connection

Ensure MongoDB is running. Check logs for any connection errors.

---

## Frontend Setup

### 1. Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

### 2. API Client Configuration

The `ApiClient` in `lib/services/api_client.dart` includes new endpoints:
- `getAiSettings()` - Fetch user AI mode and usage stats
- `updateAiSettings()` - Update AI mode and save personal key
- `testGeminiKey()` - Validate a Gemini API key
- `chatWithAi()` - Send a message to AI
- `getConversations()` - List user conversations
- `getConversationById()` - Fetch conversation history

**Configure backend URL:**

In `lib/services/api_client.dart`, update the `baseUrl`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:5000/api';
```

For local development: `http://localhost:5000/api` or `http://10.0.2.2:5000/api` (Android emulator)

### 3. New Screens

#### AI Settings Screen (`lib/screens/ai_settings_screen.dart`)
- Toggle between "App AI" and "BYOK" modes
- Enter personal Gemini API key (secure input)
- Test API key before saving
- Shows success/error toast notifications

Access from Dashboard menu → "AI Settings"

#### AI Chat Screen (`lib/screens/ai_chat_screen.dart`)
- Send messages to AI assistant
- Displays conversation in real-time
- Shows loading indicators
- Error handling with friendly messages

Access from Dashboard menu → "AI Chat"

### 4. Updated Models & Providers

**User Model** (`lib/models/user_model.dart`):
- Added fields: `aiMode`, `usageCount`, `lastUsedAt`
- Updated `fromJson`, `toJson`, `copyWith` methods

**User Provider** (`lib/providers/user_provider.dart`):
- New method: `updateAiSettings(aiMode, geminiApiKey?)`
- New method: `testGeminiKey(key)`

### 5. Run Flutter App

```bash
flutter run
```

Or run on specific device:
```bash
flutter run -d <device-id>
```

---

## Testing the BYOK Flow

### Step 1: Get Your Gemini API Key
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create or copy your API key

### Step 2: Test in App

1. **Open AI Settings**
   - In dashboard, tap menu → "AI Settings"

2. **Choose BYOK Mode**
   - Select radio button "Use My Gemini API Key (BYOK)"

3. **Enter Your Key**
   - Paste your Gemini API key in the text field

4. **Test API Key**
   - Press "Test API Key" button
   - Wait for success toast (validates key without saving)

5. **Save Settings**
   - Press "Save" button
   - Backend will encrypt and store key
   - Success message confirms save

6. **Use AI Chat**
   - Go to Dashboard menu → "AI Chat"
   - Send a message
   - AI responds using your key

### Step 3: Switch Back to App Mode
1. Return to AI Settings
2. Select "Use App AI (developer key)"
3. Press Save
4. AI Chat now uses company Gemini key

### Verify on Backend

```bash
# Check user record in MongoDB
db.users.findOne({ email: 'user@example.com' })

# Output should show:
{
  "_id": ObjectId(...),
  "aiMode": "byok",
  "encryptedGeminiKey": "base64:encoded:encrypted:key",
  "usageCount": 5,
  "lastUsedAt": ISODate("2026-05-19T..."),
  ...
}
```

---

## API Endpoints Reference

### AI Settings Management

**Get AI Settings**
```
GET /api/users/ai-settings
Headers: Authorization: Bearer <token>

Response:
{
  "success": true,
  "aiSettings": {
    "aiMode": "app" | "byok",
    "usageCount": 42,
    "lastUsedAt": "2026-05-19T..."
  }
}
```

**Update AI Settings**
```
PUT /api/users/ai-settings
Headers: Authorization: Bearer <token>
Body: {
  "aiMode": "app" | "byok",
  "geminiApiKey": "...only if BYOK..."
}

Response:
{
  "success": true,
  "message": "AI settings updated successfully",
  "aiSettings": {
    "aiMode": "byok",
    "hasPersonalKey": true
  }
}
```

**Test Gemini Key** (rate-limited)
```
POST /api/users/ai-settings/test-key
Headers: Authorization: Bearer <token>
Body: { "geminiApiKey": "..." }

Response (200):
{
  "success": true,
  "message": "Gemini API key is valid"
}

Response (400):
{
  "message": "Gemini API key validation failed"
}
```

### AI Chat

**Send Message**
```
POST /api/ai/chat
Headers: Authorization: Bearer <token>
Body: {
  "message": "What's a good destination for a beach vacation?",
  "conversationId": "optional-id-for-existing-conversation",
  "retries": 1
}

Response:
{
  "success": true,
  "data": {
    "conversationId": "new-or-existing-id",
    "message": {
      "role": "assistant",
      "content": "Great question! ..."
    },
    "usage": {
      "requestsUsed": 42,
      "estimatedTokens": 256
    }
  }
}
```

**Get Conversations**
```
GET /api/ai/conversations
Headers: Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": [
    {
      "_id": "conv-id-1",
      "title": "Beach vacation planning...",
      "createdAt": "2026-05-19T...",
      "updatedAt": "2026-05-19T..."
    }
  ]
}
```

**Get Conversation by ID**
```
GET /api/ai/conversations/<id>
Headers: Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "_id": "conv-id",
    "userId": "user-id",
    "title": "...",
    "messages": [
      { "role": "user", "content": "...", "createdAt": "..." },
      { "role": "assistant", "content": "...", "createdAt": "..." }
    ]
  }
}
```

**Stream Chat** (SSE)
```
POST /api/ai/chat/stream
Headers: Authorization: Bearer <token>
Body: { "message": "...", "conversationId": "optional" }

Response (Server-Sent Events):
data: {"type": "chunk", "chunk": "Great"}
data: {"type": "chunk", "chunk": " question"}
...
data: {"type": "done", "conversationId": "...", "estimatedTokens": 256}
```

---

## Rate Limiting

AI endpoints are rate-limited to prevent abuse and unexpected API costs.

**Default limits:**
- Window: 60 seconds
- Max requests: 20 per window per user

**Configuration (in `.env`):**
```
AI_RATE_LIMIT_WINDOW_MS=60000  # 60 seconds
AI_RATE_LIMIT_MAX=20           # 20 requests
```

**Rate limit exceeded response (429):**
```json
{
  "message": "Too many AI requests. Please wait and try again."
}
```

To adjust limits for production, modify `.env` and restart backend.

---

## Production Deployment

### Security Checklist

- [ ] Store `GEMINI_API_KEY` in a secure secret manager (AWS Secrets Manager, Google Cloud Secret Manager, etc.)
- [ ] Store `GEMINI_KEY_ENCRYPTION_SECRET` in a secure secret manager
- [ ] Enable HTTPS/TLS for all client ↔ backend communication
- [ ] Use environment-specific `.env` files; never commit `.env` to repo
- [ ] Verify `.gitignore` includes `.env`
- [ ] Rotate API keys regularly
- [ ] Monitor Gemini API usage and costs
- [ ] Set up alerts for unusual usage patterns
- [ ] Log request metadata (not keys) for audit trails
- [ ] Implement additional request quotas per user if needed
- [ ] Use a reverse proxy (nginx) with rate limiting in front of Express

### Environment-Specific Configurations

**Development:**
```
NODE_ENV=development
GEMINI_API_KEY=dev-key-here
AI_RATE_LIMIT_MAX=50  # Relaxed for testing
```

**Staging:**
```
NODE_ENV=staging
GEMINI_API_KEY=staging-key-here
AI_RATE_LIMIT_MAX=30
```

**Production:**
```
NODE_ENV=production
GEMINI_API_KEY=<from-secret-manager>
GEMINI_KEY_ENCRYPTION_SECRET=<from-secret-manager>
AI_RATE_LIMIT_MAX=20  # Strict limits
AI_RATE_LIMIT_WINDOW_MS=60000
```

### Database Backup

Ensure regular backups of MongoDB, especially user data with encrypted Gemini keys:

```bash
# Backup
mongodump --uri mongodb://localhost:27017/travelplanner --out /backup/

# Restore
mongorestore --uri mongodb://localhost:27017/travelplanner /backup/travelplanner/
```

### Monitoring & Logging

**Add structured logging to backend:**

```typescript
// Example: Log AI requests (not keys)
logger.info('AI chat request', {
  userId: user.id,
  aiMode: user.aiMode,
  messageLength: message.length,
  timestamp: new Date(),
});
```

**Monitor metrics:**
- Request rate and latency
- Error rates and types
- User AI mode distribution
- Gemini API token usage
- Storage size (encrypted keys)

### Docker Deployment

Example `Dockerfile` for backend:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist ./dist

EXPOSE 5000

CMD ["node", "dist/index.js"]
```

Build and run:
```bash
docker build -t travel-planner-backend .
docker run -e GEMINI_API_KEY=$GEMINI_API_KEY \
           -e MONGODB_URI=$MONGODB_URI \
           -e GEMINI_KEY_ENCRYPTION_SECRET=$GEMINI_KEY_ENCRYPTION_SECRET \
           -p 5000:5000 \
           travel-planner-backend
```

---

## Troubleshooting

### Issue: "Cannot find module 'express-rate-limit'"

**Solution:** Run `npm install` in the backend directory.

```bash
cd backend
npm install
```

### Issue: Gemini API key validation fails

**Causes:**
- Key is invalid or expired
- Key doesn't have necessary permissions
- API quotas exceeded

**Solution:**
1. Verify key in [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Generate a new key if needed
3. Check API quotas and enable if necessary

### Issue: "GEMINI_KEY_ENCRYPTION_SECRET must be set and at least 24 characters"

**Solution:** Set a valid encryption secret in `.env`:

```bash
GEMINI_KEY_ENCRYPTION_SECRET=your-super-secret-string-min-24-chars
```

### Issue: Flutter app can't connect to backend

**Causes:**
- Wrong backend URL in `ApiClient`
- Backend not running
- Network/firewall issues

**Solution:**
1. Check `ApiClient.baseUrl` in `lib/services/api_client.dart`
2. Verify backend is running: `curl http://localhost:5000/api/health`
3. For Android emulator, use `http://10.0.2.2:5000/api` instead of localhost

### Issue: Rate limit errors when testing

**Causes:**
- Too many requests in short time
- Rate limit too strict for your use case

**Solution:**
- Wait 60 seconds and retry, or
- Increase `AI_RATE_LIMIT_MAX` in `.env` and restart backend

### Issue: "Database connection failed"

**Causes:**
- MongoDB not running
- Wrong `MONGODB_URI`
- MongoDB credentials incorrect

**Solution:**
1. Verify MongoDB is running: `mongosh` or `mongo`
2. Check connection string in `.env`
3. Verify username/password if using auth

---

## File Structure

### Backend
```
backend/
├── src/
│   ├── controllers/
│   │   ├── ai.controller.ts         # AI chat endpoints
│   │   ├── user.controller.ts       # User & AI settings
│   │   └── ...
│   ├── services/
│   │   ├── gemini.service.ts        # Gemini API wrapper
│   │   └── ...
│   ├── models/
│   │   ├── User.ts                  # User schema with AI fields
│   │   ├── AiConversation.ts        # Conversation storage
│   │   └── ...
│   ├── middleware/
│   │   ├── rateLimiter.ts           # Rate limiting
│   │   ├── aiValidation.ts          # Request validation
│   │   └── ...
│   ├── routes/
│   │   ├── ai.routes.ts             # AI endpoints
│   │   ├── user.routes.ts           # User endpoints
│   │   └── ...
│   ├── utils/
│   │   ├── encryption.ts            # AES-256-GCM encryption
│   │   ├── appError.ts
│   │   └── ...
│   └── index.ts                     # Entry point
├── .env.example
├── package.json
└── tsconfig.json
```

### Frontend
```
frontend/
├── lib/
│   ├── screens/
│   │   ├── ai_settings_screen.dart   # NEW: BYOK & app mode toggle
│   │   ├── ai_chat_screen.dart       # NEW: Chat UI
│   │   ├── dashboard_screen.dart     # Updated: AI menu items
│   │   └── ...
│   ├── services/
│   │   └── api_client.dart          # Updated: AI endpoints
│   ├── providers/
│   │   ├── user_provider.dart       # Updated: AI settings methods
│   │   └── ...
│   ├── models/
│   │   └── user_model.dart          # Updated: AI fields
│   └── main.dart
├── pubspec.yaml
└── ...
```

---

## Next Steps

1. ✅ Backend integration complete
2. ✅ Flutter frontend complete
3. 📋 Deploy to staging environment
4. 📋 Load test and performance tuning
5. 📋 Security audit
6. 📋 Production deployment
7. 📋 Monitor usage and costs

---

## Support & Documentation

- [Google Generative AI SDK](https://github.com/google/generative-ai-js)
- [Gemini API Docs](https://ai.google.dev/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)

---

**Last Updated:** May 19, 2026  
**Integration Version:** 1.0.0  
**Status:** ✅ Production Ready
