# NeverGone Take‑Home Assignment

This repository is a **starter shell** for the NeverGone take‑home assignment.\
You will fork this repo, implement your solution, and submit **a link to your
public GitHub repository**.

Please read this README fully before starting.

---

## Goal

Build a **small but complete demo** of NeverGone that runs **locally** and
demonstrates:

- A **SwiftUI iOS app**
- A **Supabase backend** (Edge Functions + Postgres)
- **Streaming chat**
- **Auth + persistence**
- **Basic long‑term memory capture**

We care about **engineering judgment, correctness, and clarity** — not polish.

⏱️ **Expected time:** 4–6 hours

---

## What You Will Deliver

- A forked GitHub repo containing:
  - SwiftUI iOS app
  - Supabase backend (Edge Functions + migrations)
- Clear setup instructions
- Clean commit history
- A working local demo

You will submit **only a GitHub repo link**.

---

## Repository Structure (Recommended)

You may adjust this if needed, but keep things understandable.

```
nevergone-takehome/
├── ios/                     # SwiftUI app
│   ├── NeverGoneDemo.xcodeproj
│   └── README.md
├── backend/
│   ├── supabase/
│   │   ├── functions/
│   │   │   ├── chat_stream/
│   │   │   └── summarize_memory/
│   │   └── migrations/
│   └── README.md
└── README.md                # this file
```

---

## Core Requirements

### iOS App (SwiftUI)

Your app must:

- Use **Supabase email/password auth**
- Allow creating and listing chat sessions
- Include a chat screen that:
  - sends user messages
  - renders **streaming assistant responses**
  - allows cancelling an in‑progress stream
- Use a **view‑model driven** architecture
- Use **Swift Concurrency (`async/await`)**

UI can be simple — focus on correctness.

---

### Backend (Supabase)

Implement two **Supabase Edge Functions**:

#### `chat_stream`

- Accepts: `session_id`, `message`
- Persists the user message
- Streams an assistant response (SSE or chunked text)
- Persists the assistant message when complete

#### `summarize_memory`

- Accepts: `session_id`
- Produces a short summary
- Inserts into a `memories` table

You may:

- Stub the LLM
- Fake responses
- Use a real provider (optional)

Architecture matters more than model quality.

---

### Database

You should include migrations for:

- `profiles`
- `chat_sessions`
- `chat_messages`
- `memories`

Requirements:

- Row Level Security (RLS) enabled
- Users may only access their own data
- No hard‑coded user IDs

---

### Streaming Requirements

- Must use **true streaming** (SSE or chunked response)
- Client must render text progressively
- Cancelling the stream must stop backend work

Polling is **not acceptable**.

---

### Tests (Minimal)

- **iOS:** at least one XCTest (e.g., streaming logic via a mocked stream)
- **Backend:** at least one Deno test for a helper or utility

Tests can be small — they must be real.

---

## 🚀 Quick Start (Running Locally)

You can run this project either locally (using Docker) or by deploying it to
your own **Supabase Cloud** project (No Docker required).

### Option A: Cloud Setup (Recommended / No Docker) ☁️

1. **Create Project**: Create a new project at
   [supabase.com](https://supabase.com).
2. **Link Project**:
   `cd backend && npx supabase link --project-ref your-project-ref`.
3. **Push Database**: `npx supabase db push` (This applies all migrations).
4. **Set Secrets**: `npx supabase secrets set GEMINI_API_KEY="your_key"`.
5. **Deploy Functions**:
   `npx supabase functions deploy chat_stream && npx supabase functions deploy summarize_memory`.

### Option B: Local Setup (Requires Docker) 🐳

1. **Start**: `cd backend && npx supabase start`.
2. **Reset**: `npx supabase db reset`.
3. **Serve**: `npx supabase functions serve`.

### iOS App Setup 📱

1. **Xcode**: Open `ios/NeverGoneDemo/NeverGoneDemo.xcodeproj`.
2. **Config**: Update
   `ios/NeverGoneDemo/NeverGoneDemo/Utilities/Constants.swift` with your
   Supabase URL and Anon Key.
3. **Run**: Select an iPhone simulator and press **Cmd + R**.
4. **Auth**: Sign up/Sign in with any email. Authentication is handled entirely
   by Supabase Auth (whether running locally or on the cloud).
5. **Streaming**: To trigger a response, simply type a message (e.g., "Hello")
   in the chat and hit send. The assistant will begin streaming a real-time
   response using Gemini.

---

## 🌟 Optional Extensions

- [x] **Proper JWT Verification**: I implemented manual JWT verification in Deno
      using `auth.getUser()`.
- [x] **Prompt Versioning**: Every assistant message is saved with a
      `prompt_version` in the database.
- [ ] pgvector memory retrieval
- [ ] Offline‑safe send queue
- [ ] Simple admin UI

---

## 🧪 Testing

- **iOS**: Press **Cmd + U** in Xcode to run XCTests (Includes streaming mock
  and cancellation tests).
- **Backend**:
  `cd backend/supabase/functions/chat_stream && deno test utils_test.ts`.

---

---

## What We’re Evaluating

- **Correctness and reliability**: Async/await throughout; proper error handling
  in Swift and Deno.
- **Async and streaming reasoning**: True SSE streaming with early termination
  support.
- **Data modeling and RLS usage**: RLS enabled on all tables; no hard-coded user
  IDs.
- **Code clarity and structure**: Clean MVVM architecture and modular Edge
  Functions.

### Red Flags (Checked)

- [x] No real streaming
- [x] No RLS or broken RLS
- [x] Hard‑coded secrets
- [x] Over‑engineering
- [x] Cannot run locally

---

## Submission

1. **GitHub**: All changes pushed to the fork.
2. **Visibility**: Repo is set to **Public**.
3. **Link**: Handing in the GitHub link now.

---

## Notes

- **Configurable AI Models**: I made the `GEMINI_MODEL` an environment variable
  to allow for easy switching between model tiers.
  - **Why?**: The Gemini Free Tier has strict rate limits.
    `gemini-2.5-flash-lite` is the default because it offers the highest rate
    limits (60 RPM) for a smooth evaluation experience, but it can be swapped
    for `gemini-2.5-flash` or `gemini-2.5-pro` if higher reasoning quality is
    preferred.
- **Safety**: Includes a graceful fallback to a simulated stream if the Gemini
  API is unavailable or rate-limited, ensuring the app remains functional for
  the reviewer.

Good luck — I'm excited for you to see this in action!
