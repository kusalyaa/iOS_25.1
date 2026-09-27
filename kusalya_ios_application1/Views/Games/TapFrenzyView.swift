import SwiftUI
import Combine
import CoreLocation

struct TapFrenzyView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationService: LocationService
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var isGameOver = false
    @State private var doublePoints = false
    @State private var animateTap = false

    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var buttonSize: CGFloat {
        max(90, CGFloat(timeLeft) * 22)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.blue.opacity(0.85),
                    Color.purple.opacity(0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                if isGameOver {
                    gameOverView
                } else {
                    gameView
                }
            }
            .padding()
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundStyle(.white)
        .onReceive(timer) { _ in
            guard !isGameOver else { return }

            if timeLeft > 0 {
                timeLeft -= 1

                if timeLeft == 5 {
                    doublePoints = true
                }

                if timeLeft == 3 {
                    doublePoints = false
                }
            } else {
                endGame()
            }
        }
    }

    var gameView: some View {
        VStack(spacing: 26) {
            Text("Tap Frenzy")
                .font(.system(size: 42, weight: .black))

            HStack(spacing: 16) {
                InfoBox(title: "Time", value: "\(timeLeft)")
                InfoBox(title: "Score", value: "\(score)")
                InfoBox(title: "Best", value: "\(highScore)")
            }

            if doublePoints {
                Text("DOUBLE POINTS")
                    .font(.headline)
                    .bold()
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .transition(.scale)
            }

            Spacer()

            Button {
                score += doublePoints ? 2 : 1

                withAnimation(.spring(response: 0.18, dampingFraction: 0.35)) {
                    animateTap.toggle()
                }
            } label: {
                Text("TAP")
                    .font(.system(size: 34, weight: .black))
                    .frame(width: buttonSize, height: buttonSize)
                    .background(
                        LinearGradient(
                            colors: doublePoints ? [.orange, .yellow] : [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: buttonGlowColor, radius: 22)
                    .scaleEffect(animateTap ? 1.08 : 1.0)
            }

            Text("Button shrinks as time runs out")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))

            Spacer()
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
                item: "I just scored \(score) on Tap Frenzy — beat that!"
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
                            colors: [.green, .mint],
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

    var buttonGlowColor: Color {
        doublePoints ? .orange.opacity(0.9) : .blue.opacity(0.8)
    }

    private func endGame() {
        isGameOver = true

        if score > highScore {
            highScore = score
        }

        sessionStore.addSession(
            mode: .tapFrenzy,
            score: score,
            latitude: locationService.currentLocation?.latitude ?? 0.0,
            longitude: locationService.currentLocation?.longitude ?? 0.0
        )
    }

    private func restartGame() {
        score = 0
        timeLeft = 10
        isGameOver = false
        doublePoints = false
        animateTap = false
    }
}

struct InfoBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(value)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
