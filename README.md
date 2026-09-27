# PlayHub — Tutorial 4

PlayHub is a SwiftUI iOS app with three games. Open `kusalya_ios_application1.xcodeproj` in Xcode, select an iPhone simulator, and run the `kusalya_ios_application1` scheme.

## Architecture

- `App/` starts the app and provides shared session, location, and notification services.
- `Views/Games/` contains Tap Frenzy, Light It Up, and Quiz Rush. `Views/Tabs/` contains Home, Stats, Map, and Settings.
- `Models/` defines game modes, trivia data, and completed game sessions.
- `SessionStore` saves game sessions locally using UserDefaults. High scores and reminder settings use AppStorage.
- `TriviaService` fetches questions from Open Trivia DB; `QuizViewModel` manages quiz questions, scoring, loading, and errors.
- `LocationService` obtains location with permission. `NotificationService` schedules daily reminders.

## Features

- Tap Frenzy: ten-second tapping challenge, double points, high score, replay, and score sharing.
- Light It Up: timed reaction game with increasing difficulty, high score, replay, and score sharing.
- Quiz Rush: ten online trivia questions, score and streak tracking, retry on loading failure, and score sharing.
- Stats: total games and scores, best-score chart, game breakdown, and recent sessions.
- Map: pins showing the locations of completed games when location is available.
- Settings: daily reminder time, stats summary, and confirmation before resetting saved sessions.

## Known limitations

- Quiz Rush requires an internet connection; questions are not available offline.
- Game sessions are stored on this device and do not sync to other devices.
- A game completed without location data does not appear as a map pin.
- Resetting sessions may leave separately stored game high scores.
- Automated tests have not been added.

## Reflection

Bringing the games into one app helped me understand how a shared session store can support both statistics and the map. Handling online trivia also showed me the importance of loading and error states. In future, I would add automated tests and offline trivia questions.
