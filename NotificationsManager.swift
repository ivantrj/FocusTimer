import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()

    private init() {}

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if !granted {
                    // No-op; user denied. We’ll simply not schedule.
                }
            } catch {
                // Ignore for v1
            }
        case .denied, .authorized, .provisional, .ephemeral:
            // Nothing to do; we schedule only if authorized/provisional.
            break
        @unknown default:
            break
        }
    }

    func schedulePhaseCompletionNotification(phase: PomodoroPhase, taskTitle: String?, fireDate: Date) async {
        let center = UNUserNotificationCenter.current()

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        // Cancel any previous phase completion notifications to avoid duplicates
        await cancelPhaseNotifications()

        let content = UNMutableNotificationContent()
        switch phase {
        case .work:
            content.title = "Work session complete"
            if let taskTitle, !taskTitle.isEmpty {
                content.body = "You focused on “\(taskTitle)”. Time for a break!"
            } else {
                content.body = "Great job! Time for a break."
            }
            content.sound = .default
            content.categoryIdentifier = "pomodoro.phaseComplete"
        case .breakTime:
            content.title = "Break is over"
            content.body = "Let’s get back to focus."
            content.sound = .default
            content.categoryIdentifier = "pomodoro.phaseComplete"
        }

        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "pomodoro.phaseComplete",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // Ignore in v1
        }
    }

    func cancelPhaseNotifications() async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(withIdentifiers: ["pomodoro.phaseComplete"])
    }
}
