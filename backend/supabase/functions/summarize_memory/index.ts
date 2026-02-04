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
    const authHeader = req.headers.get('Authorization') ?? ''
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { session_id } = await req.json()

    // 1. Get User
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error('Unauthorized')

    // 2. Fetch recent messages to "summarize"
    const { data: messages, error: fetchError } = await supabaseClient
      .from('chat_messages')
      .select('content')
      .eq('session_id', session_id)
      .limit(5)
    
    if (fetchError) throw fetchError

    // 3. Simple stub summary logic
    const summary = messages && messages.length > 0 
      ? `Discussion about: ${messages[0].content.substring(0, 50)}...`
      : "Empty conversation summary."

    // 4. Insert into memories table
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
