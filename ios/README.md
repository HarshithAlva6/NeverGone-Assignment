# NeverGoneDemo iOS App

## Setup

1. **Open the Project**: Open `NeverGoneDemo/NeverGoneDemo.xcodeproj` in Xcode.
2. **Add Dependencies**:
   - Go to **File > Add Packages Dependencies...**
   - Enter URL: `https://github.com/supabase/supabase-swift`
   - Click **Add Package**
3. **Configure Environment**:
   - Open `NeverGoneDemo/Utilities/Constants.swift`.
   - Update `supabaseUrl` and `supabaseAnonKey` with your local Supabase values.
     - You can find these by running `npx supabase status` in the `backend/` directory.

## Architecture

- **MVVM**: Views observe ViewModels. ViewModels talk to Services.
- **Services**:
  - `SupabaseService`: Holds the client.
  - `AuthService`: Manages session.
  - `ChatService`: Handles data and streaming.
- **Streaming**: Uses `AsyncThrowingStream` to consume Server-Sent Events (SSE) from the `chat_stream` Edge Function.

## Running

1. Ensure your local Supabase backend is running (`supabase start` in `backend/`).
2. Run the app in a Simulator.
3. Sign up or Sign in.
4. Create a chat and start messaging.
