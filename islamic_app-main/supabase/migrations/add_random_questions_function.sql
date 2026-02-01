-- Add efficient random question fetching function
-- This function provides true random sampling from large datasets

-- Function to fetch random trivia questions efficiently
CREATE OR REPLACE FUNCTION public.fetch_random_trivia_questions(
  p_difficulty text,
  p_limit integer DEFAULT 10
)
RETURNS TABLE(
  id bigint,
  question text,
  options jsonb,
  answer text,
  context text,
  fun_fact text,
  hint text,
  difficulty text
) AS $$
BEGIN
  -- Use TABLESAMPLE for efficient random sampling on large datasets
  -- This is more efficient than ORDER BY RANDOM() for large tables
  RETURN QUERY
  SELECT 
    tq.id,
    tq.question,
    tq.options,
    tq.answer,
    tq.context,
    tq.fun_fact,
    tq.hint,
    tq.difficulty
  FROM trivia_questions tq TABLESAMPLE BERNOULLI(10) -- Sample 10% of rows
  WHERE tq.difficulty = p_difficulty
  ORDER BY RANDOM()
  LIMIT p_limit;
  
  -- If TABLESAMPLE doesn't return enough results, fall back to full table random
  IF NOT FOUND OR (SELECT COUNT(*) FROM trivia_questions WHERE difficulty = p_difficulty) < p_limit THEN
    RETURN QUERY
    SELECT 
      tq.id,
      tq.question,
      tq.options,
      tq.answer,
      tq.context,
      tq.fun_fact,
      tq.hint,
      tq.difficulty
    FROM trivia_questions tq
    WHERE tq.difficulty = p_difficulty
    ORDER BY RANDOM()
    LIMIT p_limit;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.fetch_random_trivia_questions(text, integer) TO authenticated;

-- Alternative function using OFFSET for better performance on medium datasets
CREATE OR REPLACE FUNCTION public.fetch_random_trivia_questions_offset(
  p_difficulty text,
  p_limit integer DEFAULT 10
)
RETURNS TABLE(
  id bigint,
  question text,
  options jsonb,
  answer text,
  context text,
  fun_fact text,
  hint text,
  difficulty text
) AS $$
DECLARE
  total_count integer;
  random_offset integer;
BEGIN
  -- Get total count of questions with this difficulty
  SELECT COUNT(*) INTO total_count 
  FROM trivia_questions 
  WHERE difficulty = p_difficulty;
  
  -- If we have fewer questions than requested, return all
  IF total_count <= p_limit THEN
    RETURN QUERY
    SELECT 
      tq.id,
      tq.question,
      tq.options,
      tq.answer,
      tq.context,
      tq.fun_fact,
      tq.hint,
      tq.difficulty
    FROM trivia_questions tq
    WHERE tq.difficulty = p_difficulty
    ORDER BY RANDOM();
    RETURN;
  END IF;
  
  -- Calculate random offset
  random_offset := floor(random() * (total_count - p_limit + 1));
  
  -- Return questions starting from random offset
  RETURN QUERY
  SELECT 
    tq.id,
    tq.question,
    tq.options,
    tq.answer,
    tq.context,
    tq.fun_fact,
    tq.hint,
    tq.difficulty
  FROM trivia_questions tq
  WHERE tq.difficulty = p_difficulty
  ORDER BY tq.id
  OFFSET random_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.fetch_random_trivia_questions_offset(text, integer) TO authenticated;

-- Create index for better performance on difficulty filtering
CREATE INDEX IF NOT EXISTS idx_trivia_questions_difficulty ON trivia_questions(difficulty);

-- Add comment explaining the functions
COMMENT ON FUNCTION public.fetch_random_trivia_questions(text, integer) IS 
'Fetches random trivia questions using TABLESAMPLE for efficient sampling on large datasets';

COMMENT ON FUNCTION public.fetch_random_trivia_questions_offset(text, integer) IS 
'Fetches random trivia questions using OFFSET for better performance on medium datasets';
