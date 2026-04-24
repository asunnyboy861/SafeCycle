import CryptoKit
import Foundation

final class DataExportService {

    static func exportEncryptedBackup(records: [PeriodRecord], logs: [DailyLog], encryptionKey: SymmetricKey?) -> Data? {
        let backup = EncryptedBackup(
            exportDate: Date(),
            periodRecords: records.map { PeriodRecordExport(from: $0) },
            dailyLogs: logs.map { DailyLogExport(from: $0) }
        )

        guard let jsonData = try? JSONEncoder().encode(backup) else { return nil }

        if let key = encryptionKey {
            return try? EncryptionService.encrypt(jsonData, with: key)
        }
        return jsonData
    }

    static func importEncryptedBackup(from data: Data, encryptionKey: SymmetricKey?) -> EncryptedBackup? {
        let jsonData: Data
        if let key = encryptionKey {
            guard let decrypted = try? EncryptionService.decrypt(data, with: key) else { return nil }
            jsonData = decrypted
        } else {
            jsonData = data
        }
        return try? JSONDecoder().decode(EncryptedBackup.self, from: jsonData)
    }
}

struct EncryptedBackup: Codable {
    let exportDate: Date
    let periodRecords: [PeriodRecordExport]
    let dailyLogs: [DailyLogExport]
}

struct PeriodRecordExport: Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let cycleLength: Int?
    let periodLength: Int?
    let encryptedSymptoms: Data?

    init(from record: PeriodRecord) {
        self.id = record.id
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.cycleLength = record.cycleLength
        self.periodLength = record.periodLength
        self.encryptedSymptoms = record.encryptedSymptoms
    }
}

struct DailyLogExport: Codable {
    let id: UUID
    let date: Date
    let encryptedMoods: Data?
    let encryptedPains: Data?
    let encryptedDigestions: Data?
    let encryptedSleeps: Data?
    let encryptedEnergies: Data?
    let encryptedSkins: Data?
    let encryptedNotes: Data?
    let flowLevel: Int?
    let isPeriodDay: Bool

    init(from log: DailyLog) {
        self.id = log.id
        self.date = log.date
        self.encryptedMoods = log.encryptedMoods
        self.encryptedPains = log.encryptedPains
        self.encryptedDigestions = log.encryptedDigestions
        self.encryptedSleeps = log.encryptedSleeps
        self.encryptedEnergies = log.encryptedEnergies
        self.encryptedSkins = log.encryptedSkins
        self.encryptedNotes = log.encryptedNotes
        self.flowLevel = log.flowLevel
        self.isPeriodDay = log.isPeriodDay
    }
}
