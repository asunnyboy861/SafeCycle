import Foundation

final class CyclePredictor {

    static func predictNextPeriod(from records: [PeriodRecord]) -> (date: Date, confidence: Double) {
        guard !records.isEmpty else {
            return (Date().addingTimeInterval(28 * 86400), 0.3)
        }

        let sortedRecords = records.sorted { $0.startDate > $1.startDate }
        let lastPeriodStart = sortedRecords[0].startDate

        if sortedRecords.count == 1 {
            return (lastPeriodStart.addingTimeInterval(28 * 86400), 0.5)
        }

        var totalWeight: Double = 0
        var weightedSum: Double = 0

        for i in 1..<min(sortedRecords.count, 6) {
            let days = Calendar.current.dateComponents([.day],
                from: sortedRecords[i].startDate,
                to: sortedRecords[i-1].startDate).day ?? 28
            let weight = Double(6 - i) / 5.0
            weightedSum += Double(days) * weight
            totalWeight += weight
        }

        let avgCycleLength = totalWeight > 0 ? weightedSum / totalWeight : 28.0

        let cycleLengths = (1..<min(sortedRecords.count, 6)).map { i -> Double in
            Double(Calendar.current.dateComponents([.day],
                from: sortedRecords[i].startDate,
                to: sortedRecords[i-1].startDate).day ?? 28)
        }
        let stdDev = standardDeviation(cycleLengths)
        let confidence = max(0.5, min(0.95, 1.0 - (stdDev / 14.0)))

        let predictedDate = lastPeriodStart.addingTimeInterval(avgCycleLength * 86400)
        return (predictedDate, confidence)
    }

    static func getCurrentCycleDay(lastPeriodStart: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastPeriodStart), to: calendar.startOfDay(for: Date()))
        return max(1, components.day ?? 1)
    }

    static func calculateAverageCycleLength(from records: [PeriodRecord]) -> Double {
        guard records.count >= 2 else { return 28.0 }
        let sortedRecords = records.sorted { $0.startDate < $1.startDate }
        var totalDays: Double = 0
        var count: Double = 0
        for i in 1..<sortedRecords.count {
            let days = Calendar.current.dateComponents([.day],
                from: sortedRecords[i-1].startDate,
                to: sortedRecords[i].startDate).day ?? 28
            totalDays += Double(days)
            count += 1
        }
        return count > 0 ? totalDays / count : 28.0
    }

    static func calculateAveragePeriodLength(from records: [PeriodRecord]) -> Double {
        let recordsWithEnd = records.compactMap { r -> Int? in
            guard let end = r.endDate else { return nil }
            return Calendar.current.dateComponents([.day], from: r.startDate, to: end).day
        }
        guard !recordsWithEnd.isEmpty else { return 5.0 }
        return Double(recordsWithEnd.reduce(0, +)) / Double(recordsWithEnd.count)
    }

    private static func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(values.count - 1)
        return sqrt(variance)
    }
}
