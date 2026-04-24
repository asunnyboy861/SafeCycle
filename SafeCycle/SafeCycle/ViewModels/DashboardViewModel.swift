import SwiftUI
import SwiftData
import LocalAuthentication

@Observable
final class DashboardViewModel {
    var daysUntilNextPeriod: Int = 0
    var currentPhase: CyclePhase = .follicular
    var cycleDay: Int = 1
    var predictedDate: Date = Date()
    var confidence: Double = 0.5
    var averageCycleLength: Double = 28.0
    var averagePeriodLength: Double = 5.0
    var isUnlocked: Bool = false
    var isStealthMode: Bool = false

    func updateFromRecords(_ records: [PeriodRecord]) {
        guard !records.isEmpty else { return }
        let sortedRecords = records.sorted { $0.startDate > $1.startDate }
        let lastPeriodStart = sortedRecords[0].startDate

        let prediction = CyclePredictor.predictNextPeriod(from: records)
        predictedDate = prediction.date
        confidence = prediction.confidence

        cycleDay = CyclePredictor.getCurrentCycleDay(lastPeriodStart: lastPeriodStart)
        averageCycleLength = CyclePredictor.calculateAverageCycleLength(from: records)
        averagePeriodLength = CyclePredictor.calculateAveragePeriodLength(from: records)

        currentPhase = CyclePhase.from(cycleDay: cycleDay, avgCycleLength: averageCycleLength)

        let calendar = Calendar.current
        daysUntilNextPeriod = max(0, calendar.dateComponents([.day], from: Date(), to: predictedDate).day ?? 0)
    }

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock SafeCycle to access your health data")
        } catch {
            return false
        }
    }
}
