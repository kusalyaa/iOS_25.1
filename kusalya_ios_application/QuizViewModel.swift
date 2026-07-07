import Foundation
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case failed(String)
        case finished
    }

    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: ViewState = .loading
    @Published var currentAnswers: [String] = []

    private let service = TriviaService()

    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else {
            return nil
        }

        return questions[currentIndex]
    }

    var questionProgressText: String {
        "\(currentIndex + 1) of \(questions.count)"
    }

    func loadQuestions() async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        currentAnswers = []

        do {
            questions = try await service.fetchQuestions()

            if questions.isEmpty {
                state = .failed("No questions received. Please try again.")
            } else {
                prepareAnswers()
                state = .loaded
            }
        } catch {
            state = .failed("Unable to load questions. Check internet and try again.")
        }
    }

    func answerTapped(_ answer: String) {
        guard let question = currentQuestion else {
            state = .finished
            return
        }

        if answer == question.correctAnswer {
            streak += 1
            score += 10 + streak
        } else {
            streak = 0
            score = max(0, score - 2)
        }

        goToNextQuestion()
    }

    private func goToNextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            prepareAnswers()
        } else {
            state = .finished
        }
    }

    private func prepareAnswers() {
        guard let question = currentQuestion else {
            currentAnswers = []
            return
        }

        currentAnswers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
    }
}
