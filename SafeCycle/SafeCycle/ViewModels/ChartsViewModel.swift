import SwiftUI
import SwiftData

@Observable
final class ChartsViewModel {
    var cycleLengths: [Double] = []
    var symptomFrequencies: [String: Int] = [:]
    var selectedTimeRange: TimeRange = .sixMonths

    enum TimeRange: String, CaseIterable {
        case threeMonths = "3M"
        case sixMonths = "6M"
        case twelveMonths = "12M"

        var months: Int {
            switch self {
            case .threeMonths: return 3
            case .sixMonths: return 6
            case .twelveMonths: return 12
            }
        }
    }

    func updateData(records: [PeriodRecord], logs: [DailyLog]) {
        updateCycleLengths(records: records)
        updateSymptomFrequencies(logs: logs)
    }

    private func updateCycleLengths(records: [PeriodRecord]) {
        let sortedRecords = records.sorted { $0.startDate < $1.startDate }
        cycleLengths = []
        for i in 1..<sortedRecords.count {
            let days = Calendar.current.dateComponents([.day],
                from: sortedRecords[i-1].startDate,
                to: sortedRecords[i].startDate).day ?? 28
            cycleLengths.append(Double(days))
        }
    }

    private func updateSymptomFrequencies(logs: [DailyLog]) {
        symptomFrequencies = [:]
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -selectedTimeRange.months, to: Date()) ?? Date()
        let recentLogs = logs.filter { $0.date >= cutoffDate }

        for log in recentLogs {
            if log.flowLevel != nil { symptomFrequencies["Period Flow", default: 0] += 1 }
            if log.encryptedMoods != nil { symptomFrequencies["Mood", default: 0] += 1 }
            if log.encryptedPains != nil { symptomFrequencies["Pain", default: 0] += 1 }
            if log.encryptedDigestions != nil { symptomFrequencies["Digestion", default: 0] += 1 }
            if log.encryptedSleeps != nil { symptomFrequencies["Sleep", default: 0] += 1 }
            if log.encryptedEnergies != nil { symptomFrequencies["Energy", default: 0] += 1 }
            if log.encryptedSkins != nil { symptomFrequencies["Skin", default: 0] += 1 }
        }
    }
}
