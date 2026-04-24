import SwiftData
import Foundation

@Model
final class DailyLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var encryptedMoods: Data?
    var encryptedPains: Data?
    var encryptedDigestions: Data?
    var encryptedSleeps: Data?
    var encryptedEnergies: Data?
    var encryptedSkins: Data?
    var encryptedNotes: Data?
    var flowLevel: Int?
    var isPeriodDay: Bool
    var createdAt: Date
    var updatedAt: Date

    init(date: Date) {
        self.id = UUID()
        self.date = date
        self.isPeriodDay = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
