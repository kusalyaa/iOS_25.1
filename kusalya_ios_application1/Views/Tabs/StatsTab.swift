import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var sessionStore: SessionStore

    private var totalGames: Int {
        sessionStore.sessions.count
    }

    private var totalScore: Int {
        sessionStore.sessions.map { $0.score }.reduce(0, +)
    }

    private var recentSessions: [GameSession] {
        Array(sessionStore.sessions.prefix(10))
    }

    private var chartData: [ModeStats] {
        GameMode.allCases.map { mode in
            ModeStats(
                mode: mode,
                gamesPlayed: sessionStore.totalGames(for: mode),
                bestScore: sessionStore.bestScore(for: mode),
                totalScore: sessionStore.sessions(for: mode).map { $0.score }.reduce(0, +)
            )
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.blue.opacity(0.75),
                    Color.purple.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    headerView

                    if sessionStore.sessions.isEmpty {
                        emptyStatsView
                    } else {
                        overviewCards
                        bestScoreChart
                        modeBreakdownView
                        recentGamesView
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 52))
                .foregroundStyle(.white)

            Text("Your Stats")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(.white)

            Text("Track your progress across all game modes")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var emptyStatsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.8))

            Text("No games played yet")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)

            Text("Complete Tap Frenzy, Light It Up, or Quiz Rush to see your results here.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var overviewCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Games",
                value: "\(totalGames)",
                icon: "gamecontroller.fill"
            )

            StatCard(
                title: "Total Score",
                value: "\(totalScore)",
                icon: "star.fill"
            )
        }
    }

    private var bestScoreChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Best Score by Mode")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            Chart(chartData) { item in
                BarMark(
                    x: .value("Game Mode", item.mode.title),
                    y: .value("Best Score", item.bestScore)
                )
                .foregroundStyle(by: .value("Mode", item.mode.title))
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var modeBreakdownView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mode Breakdown")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            ForEach(chartData) { item in
                ModeStatsRow(item: item)
            }
        }
    }

    private var recentGamesView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Games")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            ForEach(recentSessions) { session in
                RecentGameRow(session: session)
            }
        }
    }
}

struct ModeStats: Identifiable {
    let mode: GameMode
    let gamesPlayed: Int
    let bestScore: Int
    let totalScore: Int

    var id: String {
        mode.rawValue
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.yellow)

            Text(value)
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct ModeStatsRow: View {
    let item: ModeStats

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.mode.iconName)
                .font(.title2)
                .foregroundStyle(.yellow)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.mode.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Games: \(item.gamesPlayed)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Best")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text("\(item.bestScore)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct RecentGameRow: View {
    let session: GameSession

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: session.mode.iconName)
                .font(.title2)
                .foregroundStyle(.mint)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.mode.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text("\(session.score)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
