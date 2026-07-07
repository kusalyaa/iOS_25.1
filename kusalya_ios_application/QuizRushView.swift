import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()

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
                Text(decodeHTML(question.question))
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
                        } label: {
                            Text(decodeHTML(answer))
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

            Button {
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

    private func decodeHTML(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else {
            return text
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let decoded = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        )

        return decoded?.string ?? text
    }
}
