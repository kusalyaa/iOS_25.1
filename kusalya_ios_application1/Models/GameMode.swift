import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .tapFrenzy:
            return "Tap Frenzy"
        case .lightItUp:
            return "Light It Up"
        case .quizRush:
            return "Quiz Rush"
        }
    }

    var iconName: String {
        switch self {
        case .tapFrenzy:
            return "hand.tap.fill"
        case .lightItUp:
            return "bolt.fill"
        case .quizRush:
            return "questionmark.circle.fill"
        }
    }
}
