# Random Questions Fetching Implementation

## Overview

This document explains the implementation of truly random question fetching for the trivia system, addressing the issue where `fetchRandomQuestions` was always returning the first 10 questions instead of random ones.

## Problem Statement

The original `fetchRandomQuestions` method had several issues:

1. **No Random Ordering**: It fetched questions in database order (first 10)
2. **Supabase Limitation**: Supabase limits queries to 1000 rows, but we have 1000+ questions
3. **No True Randomness**: Questions were not randomly selected from the entire dataset

## Solution Architecture

The solution implements a multi-layered approach with fallbacks:

### 1. Primary Method: Database Functions

Two PostgreSQL functions provide efficient random sampling:

#### `fetch_random_trivia_questions(p_difficulty, p_limit)`
- Uses `TABLESAMPLE BERNOULLI(10)` for efficient random sampling
- Samples 10% of rows randomly, then orders by `RANDOM()`
- Falls back to full table random if insufficient results

#### `fetch_random_trivia_questions_offset(p_difficulty, p_limit)`
- Calculates total count of questions with given difficulty
- Generates random offset within valid range
- Uses `OFFSET` and `LIMIT` for efficient pagination
- Better performance for medium-sized datasets

### 2. Fallback Method: PostgreSQL RANDOM() Ordering

```sql
SELECT * FROM trivia_questions 
WHERE difficulty = ? 
ORDER BY RANDOM() 
LIMIT ?
```

- Uses PostgreSQL's native `RANDOM()` function
- True randomness but can be slow on large datasets

### 3. Final Fallback: Client-Side Random Selection

- Fetches questions in batches of 1000 (Supabase limit)
- Combines all batches and shuffles on client side
- Returns requested number of random questions
- Handles datasets larger than 1000 questions

## Implementation Details

### Database Migration

The migration file `supabase/migrations/add_random_questions_function.sql` includes:

1. **Random sampling function** using `TABLESAMPLE`
2. **Offset-based function** for better performance
3. **Index on difficulty column** for faster filtering
4. **Proper permissions** for authenticated users

### Service Layer Changes

The `TriviaService.fetchRandomQuestions` method now:

1. **Tries database function first** (`fetch_random_trivia_questions`)
2. **Falls back to offset method** (`fetch_random_trivia_questions_offset`)
3. **Uses PostgreSQL RANDOM()** if functions don't exist
4. **Implements client-side shuffling** as final fallback

### Error Handling

- Graceful degradation through multiple fallback methods
- Comprehensive logging for debugging
- Handles edge cases (empty results, large limits, etc.)

## Performance Considerations

### Database Functions (Best Performance)
- **TABLESAMPLE**: O(n) where n is sample size, not total table size
- **OFFSET method**: O(log n) for count + O(limit) for fetch
- **Index usage**: Leverages difficulty index for fast filtering

### Fallback Methods
- **RANDOM() ordering**: O(n log n) - can be slow on large tables
- **Client-side**: O(n) for fetch + O(n) for shuffle - memory intensive

## Usage Examples

### Basic Usage
```dart
final questions = await triviaService.fetchRandomQuestions(
  difficulty: 'easy',
  limit: 10,
);
```

### Different Difficulties
```dart
final easyQuestions = await triviaService.fetchRandomQuestions(
  difficulty: 'easy',
  limit: 5,
);

final hardQuestions = await triviaService.fetchRandomQuestions(
  difficulty: 'hard',
  limit: 5,
);
```

## Testing

The implementation includes comprehensive tests covering:

1. **Model validation** - TriviaQuestion JSON parsing
2. **Parameter validation** - Difficulty and limit parameters
3. **Edge cases** - Empty results, large limits, invalid inputs
4. **Fallback logic** - Multiple fallback scenarios

## Database Schema Requirements

The solution requires the following database structure:

```sql
-- Questions table with difficulty index
CREATE TABLE trivia_questions (
  id bigserial primary key,
  question text not null,
  options jsonb not null,
  answer text not null,
  context text,
  fun_fact text,
  hint text,
  difficulty text not null check (difficulty in ('easy','medium','hard'))
);

-- Index for performance
CREATE INDEX idx_trivia_questions_difficulty ON trivia_questions(difficulty);
```

## Migration Instructions

1. **Run the migration**:
   ```sql
   -- Execute supabase/migrations/add_random_questions_function.sql
   ```

2. **Verify functions exist**:
   ```sql
   SELECT proname FROM pg_proc WHERE proname LIKE 'fetch_random_trivia_questions%';
   ```

3. **Test the functions**:
   ```sql
   SELECT * FROM fetch_random_trivia_questions('easy', 5);
   ```

## Monitoring and Debugging

### Logging
The implementation includes comprehensive logging:
- Database function calls and results
- Fallback method usage
- Error conditions and recovery

### Performance Monitoring
- Monitor query execution times
- Track fallback method usage frequency
- Monitor memory usage for client-side fallback

## Future Improvements

1. **Caching**: Implement question caching for frequently requested difficulties
2. **Weighted Random**: Add support for weighted random selection based on question popularity
3. **Batch Preloading**: Pre-load random questions for better performance
4. **Analytics**: Track question usage patterns for optimization

## Troubleshooting

### Common Issues

1. **Functions not found**: Ensure migration was applied correctly
2. **Slow performance**: Check if indexes exist on difficulty column
3. **Memory issues**: Monitor client-side fallback usage with large datasets
4. **Empty results**: Verify questions exist for requested difficulty

### Debug Commands

```sql
-- Check if functions exist
\df fetch_random_trivia_questions*

-- Test function directly
SELECT * FROM fetch_random_trivia_questions('easy', 5);

-- Check question counts by difficulty
SELECT difficulty, COUNT(*) FROM trivia_questions GROUP BY difficulty;

-- Verify index exists
\d+ trivia_questions
```

## Conclusion

This implementation provides truly random question fetching with multiple fallback mechanisms, ensuring reliability and performance across different dataset sizes and database configurations. The layered approach ensures that the system always returns random questions, even if some components fail or are unavailable.
