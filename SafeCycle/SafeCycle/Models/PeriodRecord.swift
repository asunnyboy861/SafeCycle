import SwiftData
import Foundation

@Model
final class PeriodRecord {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var cycleLength: Int?
    var periodLength: Int?
    var encryptedSymptoms: Data?
    var createdAt: Date
    var updatedAt: Date

    init(startDate: Date) {
        self.id = UUID()
        self.startDate = startDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
