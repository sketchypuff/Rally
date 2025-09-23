Rally code instructions

# Badminton Match Tracker — Simple Requirements Document (Swift / SwiftUI / Xcode)

> Plain English. Grade 5 level. Short sentences. Numbers you can point to later.

---

## 1. App Overview
1. This app helps **you** keep track of badminton matches.  
2. You can start a live match and score as you play.  
3. You can save matches and edit them later.  
4. You can see simple charts and stats about your play.  
5. The app is for personal use only. It stores data on your device.

---

## 2. Main Goals
1. Let you start a live match and change scores with big + / − buttons.  
2. Let you save matches with details (opponent, date, scores, notes).  
3. Let you edit any saved match later.  
4. Show analytics only from your point of view.  
5. Keep all data local. 

---

## 3. User Stories
- **US-001:** As a user, I want a main list of all matches so I can pick one quickly.  
- **US-002:** As a user, I want to start a live match so I can score while playing.  
- **US-003:** As a user, I want big + / − buttons for each side so I can tap easily during play.  
- **US-004:** As a user, I want an explicit “Advance to Next Set” button so sets only change when I tell them to.  
- **US-005:** As a user, I want to pause and save a match so I can resume later.  
- **US-006:** As a user, I want to create players and teams in advance so I can pick them fast.  
- **US-007:** As a user, I want to log singles and doubles matches so both match types are supported.  
- **US-008:** As a user, I want matches to be editable after saving so I can fix mistakes.  
- **US-009:** As a user, I want analytics only about matches I played so my view stays personal.  
- **US-010:** As a user, I want the deuce rule to be win-by-2 with no cap so sets can continue until someone leads by 2.

---

## 4. Features
- **F-001 — Main Match List**  
  - Shows all saved matches in a list (newest first).  
  - Appears on app launch.  
  - Error: if no matches, show “No matches yet” and a big **Start match** button.

- **F-002 — Add Match / Start Match Flow**  
  - Add players/teams, set target for each set and number of sets in the match (has to be an odd number).  
  - Starts live scoring or manual entry.  
  - Error: block start if required fields are empty.

- **F-003 — Live Scoring Screen**  
  - Shows both sides’ points with big + / − buttons.  
  - Includes **Advance to Next Set**, Pause/Save, and Undo history.  
  - Error: if save fails, show short message and keep running.

- **F-005 — Player & Team Management**  
  - Add, edit, delete players and teams.  
  - Teams store member names (for doubles).  
  - Error: block team creation if no players.

- **F-006 — Edit Saved Match**  
  - Change scores, date, notes, and participants after saving.  
  - Error: if save fails, keep old data and show message.

- **F-007 — Analytics Dashboard**  
  - Shows stats only for your matches: win rate swiftui chart and trends  
  - Error: if not enough matches, show “Not enough data yet”.

- **F-008 — Export Data**  
  - Export matches as CSV or JSON.  
  - Error: if export fails, show error message.

- **F-009 — Undo / History in Live Match**  
  - Undo last point(s). Show short history.  
  - Error: disable Undo if no history.

---

## 5. Screens
- **S-001 — Main Screen (Match List)**  
  - List of matches (date, opponent/team, W/L), Analytics button, Add Match button.  
- Card for each match with player names and score
  - Opens on app start.
- Bottom navigation with home, players, stats (analytics) and settings

- **S-002 — Add Match Menu**  
  - Choices: Start Live Match or Log Completed Match.  
  - Quick link to create player/team.  
  - From Add Match on S-001.

- **S-003 — Match Setup**  
  - Pick Player/Team A and B, target points, best-of sets, toggle for deuce.  
  - From S-002 → Start Live Match.

- **S-004 — Live Scoring Screen**  
  - Score cards, + / − buttons, Advance Set, Pause/Save, Undo, completed set list.  
  - From S-003 → Start.

- **S-005 — Post-Match Summary / Edit Screen**  
  - Set scores, final result, date, notes, Edit button.  
  - From live match Save or S-001 match tap.

- **S-006 — Player & Team Management**  
  - List of players and teams, add/edit/delete. 
- 2 categories, one for individual player, one for team 
  - From S-002 or bottom navigation on S-001.

- **S-007 — Analytics Screen**  
  - Win %, matches over time, partner breakdown, head-to-head.  
  - From bottom navigation on S-001.

- **S-008 — Settings / Export Screen**    
  - From bottom navigation S-001.

---

## 6. Data
- **D-001 — Player**: id, name, photo (optional), notes.  
- **D-002 — Team**: id, name (optional), list of player ids.  
- **D-003 — Match**: id, date/time, type (singles/doubles), player/team refs, format, target points, set scores, result (your perspective), notes, paused flag, timestamps.  
- **D-004 — Settings**: default target points, best-of, last used settings.  
- **D-005 — Live Match State**: current set points, completed sets, undo history, start time.

---

## 7. Extra Details
1. **Internet:** Not needed. Works offline.  
2. **Storage:** Local only.
3. **Permissions:** None needed.  
4. **iOS Target:** iOS 17+.  
5. **Dark Mode:** Yes, use system colors.  
6. **Localization:** English only.  
7. **Privacy:** Data stays on device. 
8. **Performance:** Live scoring must not lag.  
9. **Deuce rule:** Win-by-2, no cap.

---

## 8. Build Steps

- **B-002 — Data Models (D-001 … D-005)**  
  - Create simple structs for Player, Team, Match, Settings, LiveState.  
  - Save locally (UserDefaults or file).

- **B-003 — Main Screen UI (S-001) & F-001**  
  - Build match list. Add Add Match and Analytics buttons.  
  - Show message if list is empty.

- **B-004 — Add Match Flow (S-002, S-003) & F-002**  
  - Menu: Live Match or Completed Match.  
  - Setup form: mode, players/teams, target points, best-of.

- **B-005 — Live Scoring (S-004) & F-003, F-009**  
  - Score cards with big + / −.  
  - Advance Set button, Pause/Save, Undo.

- **B-007 — Player & Team Management (S-006) & F-005**  
  - Add/edit/delete players and teams.  
  - Teams must have players.

- **B-008 — Post-Match & Edit (S-005) & F-006**  
  - Summary after match.  
  - Edit any field later.

- **B-009 — Analytics (S-007) & F-007**  
  - Show personal stats and charts.  
  - Add filters.

- **B-010 — Settings (S-008) & F-008**  
  - Defaults and reset.

- **B-011 — Local Save & Editing**  
  - Matches save locally. Editable later.  
  - Pause/resume works.

- **B-012 — Polish & Test**  
  - Test iPhone sizes, dark mode, large text.  
  - Test undo, invalid inputs, export errors.

---

## Quick Reference
1. App opens to S-001 main list.  
2. Add Match → Live Scoring (S-003 → S-004) or Completed Match.  
3. Live Scoring: big + / −, Advance Set, pause/save, Undo.  
4. Matches editable after save.  
5. Local-only data  
6. Deuce = win-by-2, no cap.