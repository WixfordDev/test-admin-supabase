# **DeenHub Trivia – Islamic Knowledge Quiz Game**

### 🎮 Game Overview

DeenHub Trivia is an **interactive Islamic quiz game** designed to test and improve your knowledge of Islam through engaging questions. Topics include the **Qur’an, Hadith, Islamic history, prophets, law, and culture.**

---

## **1. Game Modes**

Players can choose between:

* **Solo Mode**

  * Play alone to test knowledge.
  * Direct entry—no setup required.
  * Personal best scores are recorded.

* **Group Mode** *(Supabase Realtime)*

  * Multiplayer competition with 2–4 players.
  * Options:

    * **Host Game** (premium users: `deenhub_pro`) → generates a unique room key.
    * **Join Game** → enter a valid key to join.
  * Room keys expire once the game ends.

---

## **2. Difficulty Levels**

| Difficulty | Points | Timer | Question Visibility  | Turn System     | Bonus Questions | Clue Penalty |
| ---------- | ------ | ----- | -------------------- | --------------- | --------------- | ------------ |
| **Easy**   | 10 pts | 30s   | Public (all see)     | Turn-based      | ✅               | -3 pts       |
| **Medium** | 20 pts | 30s   | Private (turn-based) | Turn-based      | ✅               | -6 pts       |
| **Hard**   | 30 pts | 30s   | Private (turn-based) | Turn-based      | ✅               | -9 pts       |

**Note:** In group mode, all difficulty levels are turn-based. The host starts first, then turns rotate among players. The difference is that in **Easy** mode, all players can see the question while waiting for their turn, whereas in **Medium** and **Hard** modes, questions are private and only visible to the current player.

---

## **3. How to Play**

1. **Choose Mode** → Solo or Group.
2. **Set Difficulty** & number of players (2–4 in group).
3. **Answer Questions** within 30s.
4. **Earn Points** → Highest score wins.

---

## **4. Special Features**

### 🔹 Bonus Questions

* Trigger: When a player answers incorrectly.
* Opponent(s) get chance to steal.
* Reward: **Original points +5 bonus.**
* 5s timer to accept/decline.

### 🔹 Timer System

* Every question: **30s countdown** with color stages:

  * **Green** = 20+ sec left
  * **Yellow** = 10–20 sec
  * **Red** = <10 sec

### 🔹 Learning Mode

* After a correct answer:

  * Show **explanation with Qur’an/Hadith references**.
  * Show **Islamic fun fact**.
  * **8s read-only pause** before "Next Turn."
  * Flip-card for extra info.

---

## **5. Clue System (Hints)**

Players can use a **Get Clue** button during their turn to reveal helpful hints at the cost of points:

* Easy → **–3 pts**
* Medium → **–6 pts**
* Hard → **–9 pts**

The hint provides additional context or narrows down the answer choices. Once used, the hint is displayed below the answer options and cannot be hidden. The point penalty is immediately deducted from the player's score.

---

## **6. Scoring & Progression**

* **Easy Qs** = 10 pts
* **Medium Qs** = 20 pts
* **Hard Qs** = 30 pts
* **Bonus Qs** = +5 pts

**Progression Features**

* Scores are saved per user.
* Global **Leaderboard** shows:

  * Best scores
  * Games played & won

---

## **7. Multiplayer Database Logic (Supabase)**

* **Realtime updates** for live multiplayer.
* Game Room:

  * **Host** creates a room → generates `room_key`.
  * Room data stored in DB (valid until game ends).
  * **Players join with key**.
* Once finished, key is expired → no late joins.
* All player actions (answers, points, timers) sync in realtime.

---

## **8. Quiz Database Structure**

**Table: `questions`**

```json
{
  "id": 1,
  "question": "How many Surahs are in the Qur’an?",
  "options": ["100", "114", "120", "130"],
  "answer": "114",
  "context": "The Qur’an contains 114 Surahs revealed to Prophet Muhammad ﷺ over 23 years. (Quran 2:2, Sahih al-Bukhari).",
  "fun_fact": "Each Surah has a unique name, like Al-Fatiha or An-Nas.",
  "hint": "It’s slightly above 110."
}
```

---

## **9. Tech Notes**

* **Solo Mode** → direct game, no DB sync needed.
* **Group Mode** → Supabase Realtime + MCP tools.
* Game logic:

  * Random questions fetched from DB.
  * Scoring, timers, and bonus logic handled server-side.

---
