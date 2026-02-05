import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? req.headers.get('X-Supabase-Auth') ?? ''
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { session_id, auth_token } = await req.json()

    // Fallback: If Authorization header is stripped by gateway, use auth_token from body
    let workingClient = supabaseClient
    if ((!authHeader || authHeader.length < 10) && auth_token) {
      workingClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: `Bearer ${auth_token}` } } }
      )
    }

    // 1. Authenticate User
    const { data: { user }, error: authError } = await workingClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    // 2. Fetch Context (Up to 50 recent messages)
    const { data: messages, error: fetchError } = await supabaseClient
      .from('chat_messages')
      .select('role, content, created_at')
      .eq('session_id', session_id)
      .order('created_at', { ascending: true })
      .limit(50)

    if (fetchError) throw fetchError

    // 3. Generate Summary with Gemini 2.5 Flash
    let summary = "Empty conversation summary."

    if (messages && messages.length > 0) {
      const conversationText = messages.map(m => `${m.role}: ${m.content}`).join("\n")
      const geminiKey = Deno.env.get('GEMINI_API_KEY')
      const geminiModel = Deno.env.get('GEMINI_MODEL') || 'gemini-2.5-flash-lite'

      if (geminiKey) {
        try {
          const prompt = `Summarize the following chat conversation in 2-3 concise sentences safely. Capture the key topics discussed:\n\n${conversationText}`

          const geminiResp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${geminiKey}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
          })

          if (!geminiResp.ok) throw new Error("Gemini API Error")

          const geminiData = await geminiResp.json()
          if (geminiData.candidates && geminiData.candidates.length > 0) {
            summary = geminiData.candidates[0].content.parts[0].text
          }
        } catch (e) {
          console.error("Gemini summarization failed:", e)
          // Fallback
          summary = `Memorized ${messages.length} messages. (AI Unavailable)`
        }
      } else {
        summary = `Memorized ${messages.length} messages. (No API Key)`
      }
    }

    // 4. Persist Memory
    const { error: memError } = await supabaseClient
      .from('memories')
      .insert({
        session_id,
        user_id: user.id,
        summary: summary
      })

    if (memError) throw memError

    return new Response(JSON.stringify({ success: true, summary }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
