import SwiftUI

struct HomeView: View {
    var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.blue.opacity(0.85),
                        Color.purple.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("Game Hub")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(.white)

                        Text("Choose your challenge")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    VStack(spacing: 18) {
                        NavigationLink {
                            TapFrenzyView()
                        } label: {
                            GameModeCard(
                                title: "Tap Frenzy",
                                subtitle: "Tap fast before time runs out",
                                colorOne: .blue,
                                colorTwo: .purple
                            )
                        }

                        NavigationLink {
                            LightItUpView()
                        } label: {
                            GameModeCard(
                                title: "Light It Up",
                                subtitle: "Tap the glowing cards",
                                colorOne: .yellow,
                                colorTwo: .orange
                            )
                        }
                        
                        NavigationLink {
                            QuizRushView()
                        } label: {
                            GameModeCard(
                                title: "Quiz Rush",
                                subtitle: "Trivia game with live API",
                                colorOne: .green,
                                colorTwo: .mint
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }

struct GameModeCard: View {
    let title: String
    let subtitle: String
    let colorOne: Color
    let colorTwo: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.title)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [colorOne, colorTwo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
    }
}
