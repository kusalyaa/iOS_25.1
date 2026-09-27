import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var notificationService: NotificationService

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeTime") private var dailyChallengeTimeValue = Date().timeIntervalSince1970

    @State private var showResetConfirmation = false

    private var dailyChallengeTime: Binding<Date> {
        Binding(
            get: {
                Date(timeIntervalSince1970: dailyChallengeTimeValue)
            },
            set: { newValue in
                dailyChallengeTimeValue = newValue.timeIntervalSince1970

                if notificationsEnabled {
                    scheduleNotification(for: newValue)
                }
            }
        )
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.orange.opacity(0.75),
                    Color.yellow.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    headerView
                    notificationSection
                    statsSection
                    resetSection
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Reset all stats?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset All Stats", role: .destructive) {
                sessionStore.resetAllSessions()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all saved game sessions. High scores stored separately may remain.")
        }
        .onAppear {
            notificationService.checkPermissionStatus()
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 52))
                .foregroundStyle(.white)

            Text("Settings")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(.white)

            Text("Manage notifications and app data")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Challenge")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Notifications")
                            .font(.headline)

                        Text(notificationService.isPermissionGranted ? "Permission granted" : "Permission not granted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: notificationsEnabled) { newValue in
                    handleNotificationToggle(newValue)
                }

                DatePicker(
                    "Challenge Time",
                    selection: dailyChallengeTime,
                    displayedComponents: .hourAndMinute
                )
                .disabled(!notificationsEnabled)

                if notificationsEnabled {
                    Text("You will receive a daily reminder at the selected time.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.white.opacity(0.92))
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stats Summary")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                SettingsInfoRow(
                    title: "Total Sessions",
                    value: "\(sessionStore.sessions.count)",
                    icon: "gamecontroller.fill"
                )

                SettingsInfoRow(
                    title: "Tap Frenzy Best",
                    value: "\(sessionStore.bestScore(for: .tapFrenzy))",
                    icon: "hand.tap.fill"
                )

                SettingsInfoRow(
                    title: "Light It Up Best",
                    value: "\(sessionStore.bestScore(for: .lightItUp))",
                    icon: "bolt.fill"
                )

                SettingsInfoRow(
                    title: "Quiz Rush Best",
                    value: "\(sessionStore.bestScore(for: .quizRush))",
                    icon: "questionmark.circle.fill"
                )
            }
        }
    }

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            Button {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset All Stats")
                        .bold()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.9))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            notificationService.requestPermission()
            scheduleNotification(for: dailyChallengeTime.wrappedValue)
        } else {
            notificationService.cancelDailyChallenge()
        }
    }

    private func scheduleNotification(for date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        notificationService.scheduleDailyChallenge(
            hour: components.hour ?? 9,
            minute: components.minute ?? 0
        )
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.yellow)
                .frame(width: 32)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Text(value)
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
        }
        .padding()
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
