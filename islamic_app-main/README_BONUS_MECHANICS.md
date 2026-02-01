# Trivia Group Game - Bonus Question Mechanics

## Overview
The trivia group game includes a bonus question mechanic that adds strategic depth to the gameplay. When a player answers a question incorrectly, their opponents have the opportunity to earn bonus points by answering the same question correctly.

## How It Works

### 1. Triggering a Bonus Question
- When a player answers a question incorrectly, a bonus question opportunity is automatically offered to their opponent(s)
- The same question that was answered incorrectly becomes available as a bonus question
- The opponent has 10 seconds to decide whether to accept the bonus question

### 2. Bonus Question Interface
- A prominent "Bonus Question!" notification appears on the opponent's screen
- The interface displays the question that was answered incorrectly
- Two options are presented:
  - **Accept** (Green button with check icon): Take the bonus question challenge
  - **Decline** (Red button with close icon): Skip the bonus question

### 3. Scoring System
- **Regular Question Correct Answer**: Standard points based on difficulty (Easy: 10, Medium: 20, Hard: 30)
- **Bonus Question Correct Answer**: Original points + 5 bonus points
- **Bonus Question Incorrect Answer**: No points awarded or deducted

### 4. Game Flow After Bonus Question
#### If Opponent Accepts and Answers Correctly:
1. Opponent receives bonus points (original points + 5)
2. Explanation is shown for 8 seconds
3. Game proceeds to the next regular question

#### If Opponent Accepts and Answers Incorrectly:
1. No bonus points awarded
2. Explanation is shown for 8 seconds
3. Game proceeds to the next regular question

#### If Opponent Declines Bonus Question:
1. No points affected
2. Game immediately proceeds to the next regular question

#### If Opponent Doesn't Respond Within 10 Seconds:
1. Bonus question automatically declines
2. Game proceeds to the next regular question

### 5. Turn-Based Considerations
- The bonus question mechanic respects the turn-based flow of the game
- After a bonus question scenario, the regular turn sequence is maintained
- The player who answered incorrectly initially does not get another chance at the same question

## Technical Implementation

### State Variables
- `_isBonusQuestion`: Tracks if the current question is a bonus question
- `_isBonusQuestionAvailable`: Tracks if a bonus question is available for acceptance
- `_bonusQuestion`: Stores the bonus question data
- `_showBonusAcceptance`: Controls visibility of the bonus acceptance UI
- `_bonusTimer`: Manages the 10-second acceptance timer

### Key Methods
- `_onAnswer()`: Handles both regular and bonus question responses
- Bonus question offering logic in the `onAction` handler for `'player_answered'` events
- Bonus question acceptance/declination handlers in the UI

## Game Exit Behavior
- When any player exits the game, the game ends immediately for all participants
- Final scores are displayed to all remaining players
- The game room is properly closed and cleaned up in the backend

## Example Scenario
1. Player A (Team A) receives a question about Islamic history
2. Player A selects an incorrect answer
3. Player B (Team B) sees a bonus question notification: "The opponent answered incorrectly. You have a chance to earn bonus points!"
4. Player B has 10 seconds to accept or decline
5. If Player B accepts and answers correctly, they receive the original points plus 5 bonus points
6. If Player B declines or answers incorrectly, the game proceeds to the next regular question
7. The turn sequence continues normally after the bonus question scenario

## Benefits
- Adds strategic elements to the game
- Rewards attentive players who notice opponents' mistakes
- Creates come-back opportunities for trailing teams
- Maintains engagement throughout the game