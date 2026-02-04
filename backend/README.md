Work Overview -

1. mkdir ios backend
2. cd backend
3. npx supabase init
4. npx supabase migration new nevergone_init Created Migration Tables -
   profiles, chat_sessions, chat_messages, memories
5. npx supabase link --project-ref rszmklopocjrivvgrqbt
6. npx supabase db push
7. npx supabase functions new chat_stream
8. npx supabase functions new summarize_memory
9. npx supabase functions deploy chat_stream
10. npx supabase functions deploy summarize_memory
