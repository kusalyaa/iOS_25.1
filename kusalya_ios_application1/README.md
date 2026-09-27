# PlayHub iOS Application

## Overview

PlayHub is a SwiftUI iOS game hub application developed for the iOS App Development coursework. The app contains three game modes inside a structured app shell with real platform features such as statistics, maps, local notifications, persistent storage, and score sharing.

## Game Modes

### 1. Tap Frenzy

Tap Frenzy is a 10-second tapping game. The player taps the central button as many times as possible before the timer ends.

Features:
- 10-second countdown timer
- Score tracking
- High score persistence using AppStorage
- Shrinking button challenge
- Double points bonus challenge
- Share score support

### 2. Light It Up

Light It Up is a grid-based reaction game. Cards light up randomly and the player must tap the glowing card before it changes.

Features:
- 60-second round
- Level progression
- Increasing grid difficulty
- Multiple cards lit in the final level
- Score penalty for wrong taps
- High score persistence using AppStorage
- Share score support

### 3. Quiz Rush

Quiz Rush is a trivia game powered by the Open Trivia DB API.

Features:
- Fetches 10 questions from a live API
- Uses async/await and URLSession
- Decodes JSON using Codable
- Uses a ViewModel for quiz logic
- Loading, error, loaded, and finished states
- Score and streak tracking
- Share score support

## App Structure

The project is organized into clear folders:

```text
App/
Models/
Services/
ViewModels/
Views/
Views/Tabs/
Views/Games/
Views/Shared/
