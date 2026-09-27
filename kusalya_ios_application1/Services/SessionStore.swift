import Foundation
import Combine

@MainActor
class SessionStore: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "savedGameSessions"

    init() {
        loadSessions()
    }

    func addSession(
        mode: GameMode,
        score: Int,
        latitude: Double = 0.0,
        longitude: Double = 0.0
    ) {
        let session = GameSession(
            mode: mode,
            score: score,
            latitude: latitude,
            longitude: longitude
        )

        sessions.insert(session, at: 0)
        saveSessions()
            
        //debug line add to check session
        print("Saved session: \(mode.title), score: \(score)")
        print("Total sessions: \(sessions.count)")
    }

    func resetAllSessions() {
        sessions.removeAll()
        saveSessions()
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }

    func bestScore(for mode: GameMode) -> Int {
        sessions(for: mode)
            .map { $0.score }
            .max() ?? 0
    }

    func totalGames(for mode: GameMode) -> Int {
        sessions(for: mode).count
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save sessions: \(error.localizedDescription)")
        }
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            sessions = []
            return
        }

        do {
            sessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
            sessions = []
        }
    }
}
