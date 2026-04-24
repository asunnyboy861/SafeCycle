import CryptoKit
import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var realPin: String = ""
    var stealthPin: String = ""
    var isFaceIDEnabled: Bool = false
    var notificationHour: Int = 9
    var notificationMinute: Int = 0
    var notificationsEnabled: Bool = false
    var showExportSuccess: Bool = false
    var showExportError: Bool = false

    init() {
        realPin = KeychainHelper.shared.get(key: "real_pin") ?? ""
        stealthPin = KeychainHelper.shared.get(key: "stealth_pin") ?? ""
        isFaceIDEnabled = UserDefaults.standard.bool(forKey: "face_id_enabled")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        notificationHour = UserDefaults.standard.integer(forKey: "notification_hour") != 0 ? UserDefaults.standard.integer(forKey: "notification_hour") : 9
        notificationMinute = UserDefaults.standard.integer(forKey: "notification_minute")
    }

    func saveRealPin(_ pin: String) {
        realPin = pin
        KeychainHelper.shared.set(key: "real_pin", value: pin)
    }

    func saveStealthPin(_ pin: String) {
        stealthPin = pin
        KeychainHelper.shared.set(key: "stealth_pin", value: pin)
    }

    func toggleFaceID(_ enabled: Bool) {
        isFaceIDEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "face_id_enabled")
    }

    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notifications_enabled")
        if enabled {
            Task {
                let granted = await StealthNotificationService.requestAuthorization()
                if granted {
                    StealthNotificationService.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                }
            }
        } else {
            StealthNotificationService.cancelAllNotifications()
        }
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        notificationHour = hour
        notificationMinute = minute
        UserDefaults.standard.set(hour, forKey: "notification_hour")
        UserDefaults.standard.set(minute, forKey: "notification_minute")
        if notificationsEnabled {
            StealthNotificationService.scheduleDailyReminder(hour: hour, minute: minute)
        }
    }

    func exportData(records: [PeriodRecord], logs: [DailyLog], encryptionKey: SymmetricKey?) -> Data? {
        return DataExportService.exportEncryptedBackup(records: records, logs: logs, encryptionKey: encryptionKey)
    }
}
