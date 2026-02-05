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

### 4. Running the App
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

2. **Verify Summarization**:
   - Exchange 3-4 messages.
   - Tap **"Summarize"** (top right).
   - A purple box should appear at the top with a concise 2-3 sentence summary of the chat.

3. **Verify Persistence**:
   - Go back to the main list.
   - Tap the chat again. The history and summary should load instantly.
