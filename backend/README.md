# NeverGoneDemo Backend (Supabase) ☁️

This directory contains the Supabase project configuration and Edge Functions
that power the AI chat capabilities.

## 📂 Functions

### 1. `chat_stream`

- **Path**: `supabase/functions/chat_stream/index.ts`
- **Purpose**: Handles real-time chat interactions.
- **Key Logic**:
  - Receives user message.
  - Calls **Google Gemini API (gemini-2.5-flash)** with streaming enabled.
  - Pipes the streaming response directly to the client as Server-Sent Events
    (SSE).
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

**For Interviewers/Evaluators:**

The backend requires a Google Gemini API key. To test this project:

1. **Get a free Gemini API key**: Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. **Set the secret** in your Supabase project:

```bash
npx supabase secrets set GEMINI_API_KEY="your_actual_key_here"
```

3. **(Optional) Configure the model**:

By default, the functions use `gemini-2.5-flash-lite` for higher rate limits. You can change this:

```bash
# Use the faster, higher-quality model (lower rate limits)
npx supabase secrets set GEMINI_MODEL="gemini-2.5-flash"

# Or use the most capable model (lowest rate limits)
npx supabase secrets set GEMINI_MODEL="gemini-2.5-pro"
```

**Available models:**
- `gemini-2.5-flash-lite` (default) - Highest rate limits, good quality
- `gemini-2.5-flash` - Faster, higher quality, moderate rate limits
- `gemini-2.5-pro` - Best quality, lowest rate limits

**Alternative for local testing** (if using `supabase start`):
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your key and preferred model
# Then the local Supabase will pick it up automatically
```

_(Note: `SUPABASE_URL` and `SUPABASE_ANON_KEY` are auto-injected by Supabase)_

---

## 🧪 Testing

To run the backend utility tests, ensure you have [Deno](https://deno.land/)
installed and run:

```bash
cd supabase/functions/chat_stream
deno test utils_test.ts
```

---

## 🧠 AI Model

- **Default Model**: `gemini-2.5-flash-lite`
- **Configurable**: Set via `GEMINI_MODEL` environment variable
- **Reasoning**: Flash Lite chosen as default for its higher rate limits while maintaining good quality, ideal for demos and development.

### Model Selection Guide

| Model | Speed | Quality | Rate Limits | Best For |
|-------|-------|---------|-------------|----------|
| `gemini-2.5-flash-lite` | Fast | Good | **Highest** (60 RPM) | Development, demos |
| `gemini-2.5-flash` | Faster | Better | Moderate (15 RPM) | Production |
| `gemini-2.5-pro` | Slower | Best | Lowest (2 RPM) | Complex tasks |

**Note**: If you hit rate limits with one model, switch to `gemini-2.5-flash-lite` for higher throughput.

### Important Note on Streaming Behavior

While the implementation uses **true streaming** (Server-Sent Events), the Gemini Flash models generate tokens so quickly that the streaming effect may appear almost instantaneous. This is a characteristic of the model's performance, not a limitation of the streaming implementation. The backend correctly streams each chunk as it arrives from the Gemini API.

---

## ⚠️ Gemini API Rate Limits & Fallback

### Free Tier Limits

The Gemini API free tier has the following limits:
- **15 requests per minute (RPM)**
- **1,500 requests per day**
- **1 million tokens per day**

### Graceful Fallback

If the Gemini API is unavailable (due to rate limits, network issues, or missing API key), the functions automatically fall back to a **simulated streaming response**. This ensures:

✅ The streaming architecture can still be demonstrated  
✅ The app remains functional even without AI  
✅ Graceful degradation instead of hard failures

**Example fallback response:**
```
"This is a simulated streaming response (Gemini API unavailable). Processing: [user message]"
```

### If You Hit Rate Limits

1. **Wait**: RPM limits reset after 1 minute; daily limits reset at midnight PT
2. **New API Key**: Create a fresh key at [Google AI Studio](https://aistudio.google.com/app/apikey)
3. **Update Secret**:
   ```bash
   npx supabase secrets set GEMINI_API_KEY="your_new_key"
   ```
