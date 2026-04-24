import SwiftUI
import SwiftData
import CryptoKit

@Observable
final class LogViewModel {
    var selectedMoods: Set<String> = []
    var selectedPains: Set<String> = []
    var selectedDigestions: Set<String> = []
    var selectedSleeps: Set<String> = []
    var selectedEnergies: Set<String> = []
    var selectedSkins: Set<String> = []
    var flowLevel: Int? = nil
    var notes: String = ""
    var isPeriodDay: Bool = false
    var isSaving: Bool = false

    let moodOptions = ["Happy", "Calm", "Anxious", "Sad", "Irritable", "Energetic", "Tired", "Emotional"]
    let painOptions = ["Cramps", "Headache", "Back Pain", "Breast Tenderness", "Joint Pain", "None"]
    let digestionOptions = ["Normal", "Bloating", "Nausea", "Constipation", "Diarrhea", "Appetite Changes"]
    let sleepOptions = ["Great", "Good", "Fair", "Poor", "Insomnia", "Oversleeping"]
    let energyOptions = ["High", "Medium", "Low", "Exhausted"]
    let skinOptions = ["Clear", "Acne", "Dry", "Oily", "Sensitive"]

    func saveLog(for date: Date, modelContext: ModelContext, encryptionKey: SymmetricKey?) {
        isSaving = true
        defer { isSaving = false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)

        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay })

        let existingLog = try? modelContext.fetch(descriptor).first

        let log = existingLog ?? DailyLog(date: date)
        log.flowLevel = flowLevel
        log.isPeriodDay = isPeriodDay
        log.updatedAt = Date()

        if let key = encryptionKey {
            if !selectedMoods.isEmpty { log.encryptedMoods = try? EncryptionService.encryptJSON(Array(selectedMoods), with: key) }
            if !selectedPains.isEmpty { log.encryptedPains = try? EncryptionService.encryptJSON(Array(selectedPains), with: key) }
            if !selectedDigestions.isEmpty { log.encryptedDigestions = try? EncryptionService.encryptJSON(Array(selectedDigestions), with: key) }
            if !selectedSleeps.isEmpty { log.encryptedSleeps = try? EncryptionService.encryptJSON(Array(selectedSleeps), with: key) }
            if !selectedEnergies.isEmpty { log.encryptedEnergies = try? EncryptionService.encryptJSON(Array(selectedEnergies), with: key) }
            if !selectedSkins.isEmpty { log.encryptedSkins = try? EncryptionService.encryptJSON(Array(selectedSkins), with: key) }
            if !notes.isEmpty { log.encryptedNotes = try? EncryptionService.encryptJSON(notes, with: key) }
        }

        if existingLog == nil {
            modelContext.insert(log)
        }
        try? modelContext.save()
    }

    func loadLog(for date: Date, logs: [DailyLog], encryptionKey: SymmetricKey?) {
        let calendar = Calendar.current
        guard let log = logs.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) else {
            resetSelections()
            return
        }

        flowLevel = log.flowLevel
        isPeriodDay = log.isPeriodDay

        if let key = encryptionKey {
            if let data = log.encryptedMoods { selectedMoods = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedPains { selectedPains = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedDigestions { selectedDigestions = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedSleeps { selectedSleeps = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedEnergies { selectedEnergies = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedSkins { selectedSkins = (try? EncryptionService.decryptJSON([String].self, from: data, with: key))?.reduce(into: Set()) { $0.insert($1) } ?? [] }
            if let data = log.encryptedNotes { notes = (try? EncryptionService.decryptJSON(String.self, from: data, with: key)) ?? "" }
        }
    }

    func resetSelections() {
        selectedMoods = []
        selectedPains = []
        selectedDigestions = []
        selectedSleeps = []
        selectedEnergies = []
        selectedSkins = []
        flowLevel = nil
        notes = ""
        isPeriodDay = false
    }
}
