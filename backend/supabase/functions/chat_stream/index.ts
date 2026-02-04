import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization') ?? ''
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { session_id, message } = await req.json()

    // 1. Get User ID from Auth
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    // 2. Persist User Message
    const { error: msgError } = await supabaseClient
      .from('chat_messages')
      .insert({
        session_id,
        author_id: user.id,
        content: message,
        role: 'user'
      })
    if (msgError) throw msgError

    // 3. Prepare Stream
    const encoder = new TextEncoder()
    const stream = new ReadableStream({
      async start(controller) {
        const fullResponse = "This is a simulated streaming response from NeverGone. I am processing your message: " + message
        const chunks = fullResponse.split(' ')
        let currentResponse = ""

        for (const chunk of chunks) {
          const text = chunk + " "
          currentResponse += text
          controller.enqueue(encoder.encode(text))
          // Simulate network delay
          await new Promise(r => setTimeout(r, 100))
        }

        // 4. Persist Assistant Message when complete
        await supabaseClient
          .from('chat_messages')
          .insert({
            session_id,
            author_id: user.id, // In a real app, you might use a system ID, but for RLS 'author_id' must be the user or handled by service role
            content: currentResponse.trim(),
            role: 'assistant'
          })

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
