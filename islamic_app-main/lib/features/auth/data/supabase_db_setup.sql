-- Create user profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  has_subscription BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable Row Level Security on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_profiles
CREATE POLICY "Users can view their own profile" 
  ON user_profiles FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" 
  ON user_profiles FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create normalized memorization data tables
CREATE TABLE IF NOT EXISTS user_memorization (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  memorized_count INT DEFAULT 0,
  reviewing_count INT DEFAULT 0,
  learning_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id)
);

-- Table for individual verse progress
CREATE TABLE IF NOT EXISTS verse_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  surah_id INT NOT NULL,
  verse_id INT NOT NULL,
  status INT NOT NULL, -- 0=notStarted, 1=learning, 2=reviewing, 3=memorized
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),
  device_id TEXT,
  UNIQUE(user_id, surah_id, verse_id)
);

-- Table for recently read verses
CREATE TABLE IF NOT EXISTS recently_read (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  surah_id INT NOT NULL,
  verse_id INT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  device_id TEXT,
  UNIQUE(user_id, surah_id, verse_id)
);

-- Enable Row Level Security on all memorization tables
ALTER TABLE user_memorization ENABLE ROW LEVEL SECURITY;
ALTER TABLE verse_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE recently_read ENABLE ROW LEVEL SECURITY;

-- Create policies for user_memorization
CREATE POLICY "Users can view their own memorization data" 
  ON user_memorization FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own memorization data" 
  ON user_memorization FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own memorization data" 
  ON user_memorization FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create policies for verse_progress
CREATE POLICY "Users can view their own verse progress" 
  ON verse_progress FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own verse progress" 
  ON verse_progress FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own verse progress" 
  ON verse_progress FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create policies for recently_read
CREATE POLICY "Users can view their own recently read verses" 
  ON recently_read FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own recently read verses" 
  ON recently_read FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own recently read verses" 
  ON recently_read FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to all tables with updated_at column
CREATE TRIGGER update_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_memorization_updated_at
BEFORE UPDATE ON user_memorization
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle new user registration with proper error handling
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  -- Insert user profile (use ON CONFLICT to handle existing users)
  INSERT INTO public.user_profiles (user_id, email, full_name)
  VALUES (
    NEW.id, 
    NEW.email, 
    NEW.raw_user_meta_data->>'full_name'
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    updated_at = now();
  
  -- Initialize user memorization record (use ON CONFLICT to handle existing users)
  INSERT INTO public.user_memorization (user_id, memorized_count, reviewing_count, learning_count)
  VALUES (NEW.id, 0, 0, 0)
  ON CONFLICT (user_id) DO NOTHING; -- Don't update existing memorization data
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE NOTICE 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_verse_progress_device ON verse_progress(device_id);
CREATE INDEX IF NOT EXISTS idx_recently_read_device ON recently_read(device_id);
CREATE INDEX IF NOT EXISTS idx_verse_progress_updated ON verse_progress(last_updated);
CREATE INDEX IF NOT EXISTS idx_recently_read_timestamp ON recently_read(timestamp);

-- Migration script to add device_id column to existing tables (run only if needed)
DO $$
BEGIN
  -- Add device_id column to verse_progress if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'verse_progress' AND column_name = 'device_id'
  ) THEN
    ALTER TABLE verse_progress ADD COLUMN device_id TEXT;
    RAISE NOTICE 'Added device_id column to verse_progress table';
  END IF;
  
  -- Add device_id column to recently_read if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'recently_read' AND column_name = 'device_id'
  ) THEN
    ALTER TABLE recently_read ADD COLUMN device_id TEXT;
    RAISE NOTICE 'Added device_id column to recently_read table';
  END IF;
END $$; 