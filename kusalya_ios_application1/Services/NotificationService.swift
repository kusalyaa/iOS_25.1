import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationService: ObservableObject {
    @Published var isPermissionGranted = false

    init() {
        checkPermissionStatus()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            Task { @MainActor in
                self.isPermissionGranted = granted

                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }

    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleDailyChallenge(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Ready to beat your best score today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "dailyChallengeNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["dailyChallengeNotification"]
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled at \(hour):\(minute)")
            }
        }
    }

    func cancelDailyChallenge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["dailyChallengeNotification"]
        )

        print("Daily notification cancelled")
    }
}
