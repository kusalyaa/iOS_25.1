import SwiftUI
import Combine
import CoreLocation

struct LightCard: Identifiable {
    let id = UUID()
    var isLit = false
}

struct LightItUpView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationService: LocationService
    @State private var cards: [LightCard] = Array(repeating: LightCard(), count: 3)
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var isGameOver = false
    @State private var level = 1

    @AppStorage("lightItUpHighScore") private var highScore = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var cardCount: Int {
        if timeLeft > 45 {
            return 3
        } else if timeLeft > 30 {
            return 4
        } else if timeLeft > 15 {
            return 6
        } else {
            return 9
        }
    }

    var columnCount: Int {
        if cardCount == 3 {
            return 3
        } else if cardCount == 4 {
            return 2
        } else {
            return 3
        }
    }

    var litCardCount: Int {
        level == 4 ? 2 : 1
    }

    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }

    var levelColor: Color {
        switch level {
        case 1:
            return .yellow
        case 2:
            return .orange
        case 3:
            return .green
        default:
            return .pink
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.orange.opacity(0.7),
                    Color.yellow.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                if isGameOver {
                    gameOverView
                } else {
                    gameView
                }
            }
            .padding()
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundStyle(.white)
        .onAppear {
            resetCardsIfNeeded()
            lightRandomCards()
        }
        .onReceive(timer) { _ in
            guard !isGameOver else { return }

            if timeLeft > 0 {
                timeLeft -= 1
                updateLevel()
                resetCardsIfNeeded()
                lightRandomCards()
            } else {
                endGame()
            }
        }
    }

    var gameView: some View {
        VStack(spacing: 22) {
            Text("Light It Up")
                .font(.system(size: 40, weight: .black))

            HStack(spacing: 12) {
                InfoBox(title: "Time", value: "\(timeLeft)")
                InfoBox(title: "Score", value: "\(score)")
                InfoBox(title: "Level", value: "\(level)")
            }

            Text("Tap the glowing card before it changes")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(cards.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            cards[index].isLit
                            ? levelColor
                            : Color.white.opacity(0.18)
                        )
                        .frame(height: 105)
                        .overlay {
                            if cards[index].isLit {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            }
                        }
                        .scaleEffect(cards[index].isLit ? 1.08 : 1.0)
                        .shadow(
                            color: cards[index].isLit ? levelColor.opacity(0.9) : .clear,
                            radius: 18
                        )
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: cards[index].isLit)
                        .onTapGesture {
                            handleTap(index)
                        }
                }
            }

            Spacer()

            Text("High Score: \(highScore)")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    var gameOverView: some View {
        VStack(spacing: 22) {
            Text("Game Over")
                .font(.system(size: 42, weight: .black))

            Text("Final Score")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.75))

            Text("\(score)")
                .font(.system(size: 76, weight: .black))
                .foregroundStyle(score >= highScore ? .yellow : .white)

            Text("High Score: \(highScore)")
                .font(.title3)
                .bold()
            
            ShareLink(
                item: "I just scored \(score) on Light It Up — beat that!"
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
                restartGame()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.top, 10)
        }
        .padding()
    }

    private func updateLevel() {
        if timeLeft > 45 {
            level = 1
        } else if timeLeft > 30 {
            level = 2
        } else if timeLeft > 15 {
            level = 3
        } else {
            level = 4
        }
    }

    private func resetCardsIfNeeded() {
        if cards.count != cardCount {
            cards = Array(repeating: LightCard(), count: cardCount)
        }
    }

    private func lightRandomCards() {
        for index in cards.indices {
            cards[index].isLit = false
        }

        let randomIndexes = cards.indices.shuffled().prefix(litCardCount)

        for index in randomIndexes {
            cards[index].isLit = true
        }
    }

    private func handleTap(_ index: Int) {
        if cards[index].isLit {
            score += 1
        } else {
            score = max(0, score - 1)
        }

        lightRandomCards()
    }

    private func endGame() {
        isGameOver = true

        if score > highScore {
            highScore = score
        }

        sessionStore.addSession(
            mode: .lightItUp,
            score: score,
            latitude: locationService.currentLocation?.latitude ?? 0.0,
            longitude: locationService.currentLocation?.longitude ?? 0.0
        )
    }

    private func restartGame() {
        score = 0
        timeLeft = 60
        level = 1
        isGameOver = false
        cards = Array(repeating: LightCard(), count: 3)
        lightRandomCards()
    }
}
