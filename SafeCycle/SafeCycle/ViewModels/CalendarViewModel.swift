import SwiftUI
import SwiftData

@Observable
final class CalendarViewModel {
    var selectedMonth: Date = Date()
    var selectedDate: Date? = nil

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else { return [] }
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        return range.compactMap { day -> Date? in
            var comp = components
            comp.day = day
            return calendar.date(from: comp)
        }
    }

    func firstWeekdayOffset() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1
    }

    func previousMonth() {
        guard let date = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) else { return }
        selectedMonth = date
    }

    func nextMonth() {
        guard let date = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) else { return }
        selectedMonth = date
    }

    func isPeriodDay(_ date: Date, records: [PeriodRecord]) -> Bool {
        let calendar = Calendar.current
        return records.contains { record in
            let startDay = calendar.startOfDay(for: record.startDate)
            let endDay = record.endDate.map { calendar.startOfDay(for: $0) } ?? startDay
            let checkDay = calendar.startOfDay(for: date)
            return checkDay >= startDay && checkDay <= endDay
        }
    }

    func flowLevelForDate(_ date: Date, logs: [DailyLog]) -> Int? {
        let calendar = Calendar.current
        return logs.first { calendar.isDate($0.date, inSameDayAs: date) }?.flowLevel
    }
}
