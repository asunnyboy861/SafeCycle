import UserNotifications
import Foundation

final class StealthNotificationService {

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["safecycle-daily-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Time for your daily check-in"
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "safecycle-daily-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    static func scheduleUpcomingPeriodAlert(on date: Date, hour: Int = 9) {
        guard let alertDate = Calendar.current.date(byAdding: .day, value: -3, to: date) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Weekly Update"
        content.body = "Your weekly summary is ready"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: alertDate)
        dateComponents.hour = hour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "safecycle-period-alert-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
