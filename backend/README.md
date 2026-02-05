# NeverGoneDemo Backend (Supabase) ☁️

This directory contains the Supabase project configuration and Edge Functions that power the AI chat capabilities.

## 📂 Functions

### 1. `chat_stream`
- **Path**: `supabase/functions/chat_stream/index.ts`
- **Purpose**: Handles real-time chat interactions.
- **Key Logic**:
  - Receives user message.
  - Calls **Google Gemini API (gemini-2.5-flash)** with streaming enabled.
  - Pipes the streaming response directly to the client as Server-Sent Events (SSE).
  - Persists both user and assistant messages to the database.

### 2. `summarize_memory`
- **Path**: `supabase/functions/summarize_memory/index.ts`
- **Purpose**: Generates concise session summaries.
- **Key Logic**:
  - Fetches the last 50 messages of a session.
  - Contextualizes them into a prompt for Gemini.
  - Asks for a "concise, human-like" summary.
  - Saves the result to the `memories` table in Supabase.

---

## 🛠 Local Development & Deployment

### Prerequisites
- [Supabase CLI](https://supabase.com/docs/guides/cli) installed.
- Docker (for local testing).

### Deployment
To deploy these functions to the linked Supabase project:

```bash
# 1. Login
npx supabase login

# 2. Deploy specific functions
npx supabase functions deploy chat_stream
npx supabase functions deploy summarize_memory
```

### Configuration (Secrets)
The functions rely on the following secrets being set in the Supabase Dashboard or via CLI:

```bash
npx supabase secrets set GEMINI_API_KEY="AIzaSy..."
```

*(Note: `SUPABASE_URL` and `SUPABASE_ANON_KEY` are auto-injected)*

---

## 🧠 AI Model
- **Model**: `gemini-2.5-flash`
- **Reasoning**: Chosen for its extremely low latency and high tokens-per-second, which is ideal for real-time chat streaming.
