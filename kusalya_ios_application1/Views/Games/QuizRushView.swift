import SwiftUI
import CoreLocation

struct QuizRushView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = QuizViewModel()
    @State private var hasSavedSession = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.green.opacity(0.75),
                    Color.mint.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            contentView
                .padding()
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundStyle(.white)
        .task {
            await viewModel.loadQuestions()
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.state {
        case .loading:
            VStack(spacing: 18) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Loading questions...")
                    .font(.headline)
            }

        case .failed(let message):
            VStack(spacing: 22) {
                Text("Something went wrong")
                    .font(.system(size: 32, weight: .black))

                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))

                Button {
                    Task {
                        await viewModel.loadQuestions()
                    }
                } label: {
                    Text("Retry")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }

        case .loaded:
            quizView

        case .finished:
            resultView
        }
    }

    var quizView: some View {
        VStack(spacing: 22) {
            Text("Quiz Rush")
                .font(.system(size: 40, weight: .black))

            HStack(spacing: 12) {
                InfoBox(title: "Question", value: viewModel.questionProgressText)
                InfoBox(title: "Score", value: "\(viewModel.score)")
                InfoBox(title: "Streak", value: "\(viewModel.streak)")
            }

            Spacer()

            if let question = viewModel.currentQuestion {
                Text(question.question)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(spacing: 14) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        Button {
                            viewModel.answerTapped(answer)
                            if case .finished = viewModel.state {
                                saveQuizSessionIfNeeded()
                            }
                        } label: {
                            Text(answer)
                                .font(.headline)
                                .bold()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }

            Spacer()
        }
    }

    var resultView: some View {
        VStack(spacing: 24) {
            Text("Quiz Complete")
                .font(.system(size: 40, weight: .black))

            Text("Final Score")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.75))

            Text("\(viewModel.score)")
                .font(.system(size: 76, weight: .black))
                .foregroundStyle(.yellow)

            Text("Best Streak: \(viewModel.streak)")
                .font(.title3)
                .bold()
            
            ShareLink(
                item: "I just scored \(viewModel.score) on Quiz Rush — beat that!"
            ) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Score")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.9))
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            
            Button {
                hasSavedSession = false
                Task {
                    await viewModel.loadQuestions()
                }
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func saveQuizSessionIfNeeded() {
        guard !hasSavedSession else {
            return
        }

        hasSavedSession = true

        sessionStore.addSession(
            mode: .quizRush,
            score: viewModel.score,
            latitude: locationService.currentLocation?.latitude ?? 0.0,
            longitude: locationService.currentLocation?.longitude ?? 0.0
        )
    }
}
