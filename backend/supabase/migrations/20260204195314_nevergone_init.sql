-- 1. profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  last_active TIMESTAMP WITH TIME ZONE DEFAULT now(),
  handle TEXT
);

-- 2. chat_sessions
CREATE TABLE chat_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  title TEXT
);

-- 3. chat_messages
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES chat_sessions ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
  content TEXT NOT NULL,
  role TEXT CHECK (role IN ('user', 'assistant')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. memories
CREATE TABLE memories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES chat_sessions ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
  summary TEXT NOT NULL,
  captured_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "view_own_profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "manage_own_sessions" ON chat_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "manage_own_messages" ON chat_messages FOR ALL USING (auth.uid() = author_id);
CREATE POLICY "manage_own_memories" ON memories FOR ALL USING (auth.uid() = user_id);