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

    const { session_id, message, auth_token } = await req.json()

    let workingClient = supabaseClient
    if ((!authHeader || authHeader.length < 10) && auth_token) {
      workingClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: `Bearer ${auth_token}` } } }
      )
    }

    const { data: { user }, error: authError } = await workingClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    await supabaseClient
      .from('chat_messages')
      .insert({
        session_id,
        author_id: user.id,
        content: message,
        role: 'user'
      })

    const encoder = new TextEncoder()
    const stream = new ReadableStream({
      async start(controller) {
        let currentResponse = ""
        let usedGemini = false
        const geminiKey = Deno.env.get('GEMINI_API_KEY')

        if (geminiKey) {
          try {
            // Using Gemini 2.5 Flash with System Instruction
            const geminiResp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?key=${geminiKey}`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                systemInstruction: {
                  parts: [{ text: "You are a helpful assistant. Keep your responses concise (1-3 lines) and human-like. Only provide details if explicitly asked." }]
                },
                contents: [{ parts: [{ text: message }] }]
              })
            })

            if (geminiResp.ok && geminiResp.body) {
              usedGemini = true
              const reader = geminiResp.body.getReader()
              const decoder = new TextDecoder()
              let buffer = ""

              while (true) {
                const { done, value } = await reader.read()
                if (done) break

                buffer += decoder.decode(value, { stream: true })
                const regex = /"text":\s*"((?:[^"\\]|\\.)*)"/g
                let match
                let lastIndex = 0

                while ((match = regex.exec(buffer)) !== null) {
                  let text = match[1]
                  text = text.replace(/\\n/g, '\n').replace(/\\"/g, '"').replace(/\\\\/g, '\\')
                  currentResponse += text
                  controller.enqueue(encoder.encode(text))
                  lastIndex = regex.lastIndex
                }

                if (lastIndex > 0) {
                  buffer = buffer.slice(lastIndex)
                }
              }
            }
          } catch (e) {
            usedGemini = false
          }
        }

        if (!usedGemini || currentResponse.length === 0) {
          const fullResponse = "This is a simulated streaming response (Gemini API unavailable). Processing: " + message
          const chunks = fullResponse.split(' ')
          for (const chunk of chunks) {
            const text = chunk + " "
            currentResponse += text
            controller.enqueue(encoder.encode(text))
            await new Promise(r => setTimeout(r, 100))
          }
        }

        if (currentResponse.trim().length > 0) {
          await supabaseClient
            .from('chat_messages')
            .insert({
              session_id,
              author_id: user.id,
              content: currentResponse.trim(),
              role: 'assistant'
            })
        }

        controller.close()
      }
    })

    return new Response(stream, {
      headers: { ...corsHeaders, 'Content-Type': 'text/event-stream' },
    })

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
