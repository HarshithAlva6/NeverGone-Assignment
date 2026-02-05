# NeverGoneDemo iOS Client 📱

A production-ready SwiftUI chat application featuring real-time AI streaming and smart session summarization.

## 🚀 Quick Start

### 1. Requirements
- **Xcode 15.0+**
- **iOS 17.0+** Simulator (iPhone 15 Pro recommended)

### 2. Setup
1. Open `NeverGoneDemo.xcodeproj` in Xcode.
2. Wait for Swift Package Manager (SPM) to resolve dependencies (`supabase-swift`). 
   - If it fails, go to `File > Packages > Resolve Package Versions`.

### 3. Configuration
The app is pre-configured to connect to the deployed Supabase backend.
- **Config File**: `NeverGoneDemo/Utilities/Constants.swift`
- **Keys**: `supabaseUrl` and `supabaseAnonKey` are already set.

### 4. Backend Setup (Required)

**Before running the app**, ensure the backend is configured:

1. **Get a Gemini API Key**: Visit [Google AI Studio](https://aistudio.google.com/app/apikey) (free, takes 30 seconds)
2. **Set the secret** in Supabase:
   ```bash
   cd ../backend
   npx supabase secrets set GEMINI_API_KEY="your_actual_key_here"
   ```
3. See `../backend/README.md` for detailed backend setup instructions.

### 5. Running the App
1. Select an iOS Simulator.
2. Press **Cmd + R** to Build & Run.
3. **Sign Up**: Create a new account (e.g., `demo@test.com` / `password`).
4. **Chat**: Create a new session and start chatting with the AI.

---

## 🏗 Architecture

### MVVM + Services
- **Views**: Pure SwiftUI, observing ViewModels.
- **ViewModels**: Manage state (`@Published` properties), handle business logic, and communicate with Services.
- **Services**: Singleton layers for async operations.
  - `ChatService`: Manages data fetching and streaming using `URLSession` bytes for real-time updates.
  - `AuthService`: Wrapper around Supabase Auth.
  - `SupabaseService`: Holds the core client instance.

### Key Features
- **Streaming**: Implemented using `AsyncThrowingStream` to render AI tokens as they arrive.
- **Optimistic UI**: User messages appear immediately.
- **Summarization**: Displays a persistent "Session Summary" card at the top of the chat when generated.

---

## 🧪 Testing Guide for Interviewers

1. **Verify Streaming**:
   - Send a message like "Tell me a short story".
   - Watch the text appear token-by-token (not all at once).
   - **Note**: The Gemini 2.5 Flash model is extremely fast, so streaming may appear almost instantaneous. The implementation uses true streaming (Server-Sent Events), but the model's high tokens-per-second rate makes it less visually apparent than slower models.

2. **Verify Summarization**:
   - Exchange 3-4 messages.
   - Tap **"Summarize"** (top right).
   - A purple box should appear at the top with a concise 2-3 sentence summary of the chat.

3. **Verify Persistence**:
   - Go back to the main list.
   - Tap the chat again. The history and summary should load instantly.

---

## ✅ Automated Tests

The project includes XCTests that verify core functionality. Run tests with **Cmd + U** in Xcode.

### What's Tested

**Unit Tests** (`NeverGoneDemoTests`):

1. **ChatMessage Initialization**
   - Verifies that chat message objects are created correctly with all required fields (ID, content, role, timestamps).

2. **JSON Decoding**
   - Tests that messages from the backend API are properly decoded from JSON into Swift objects.
   - Ensures the app can correctly parse server responses.

3. **Streaming Logic** ⭐ *(Required by assignment)*
   - Uses a **mocked AsyncThrowingStream** to simulate streaming responses.
   - Verifies that chunks arrive in the correct order and can be assembled into complete messages.
   - Confirms the streaming mechanism works without requiring actual network calls.

4. **Stream Cancellation**
   - Tests that when a user cancels a streaming response, the stream stops immediately.
   - Verifies that the app doesn't continue processing chunks after cancellation.
   - Important for resource management and user experience.

### Running Tests

```bash
# In Xcode: Press Cmd + U

# Or via command line:
cd ios/NeverGoneDemo
xcodebuild test -scheme NeverGoneDemo -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

All tests should pass with green checkmarks ✅
