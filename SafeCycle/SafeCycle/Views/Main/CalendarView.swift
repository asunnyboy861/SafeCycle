import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [PeriodRecord]
    @Query private var logs: [DailyLog]
    @State private var viewModel = CalendarViewModel()
    @State private var showLogSheet = false

    var body: some View {
        VStack(spacing: 0) {
            monthNavigation
            weekdayHeaders
            calendarGrid
            Spacer()
        }
        .background(Color(hex: "0F0F23"))
        .sheet(isPresented: $showLogSheet) {
            if let date = viewModel.selectedDate {
                DailyLogSheet(date: date)
            }
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: { viewModel.previousMonth() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(hex: "F2E4BF"))
            }
            Spacer()
            Text(viewModel.monthTitle)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Button(action: { viewModel.nextMonth() }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(hex: "F2E4BF"))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var weekdayHeaders: some View {
        HStack(spacing: 4) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }

    private var calendarGrid: some View {
        let days = viewModel.daysInMonth()
        let offset = viewModel.firstWeekdayOffset()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(0..<offset, id: \.self) { _ in
                Color.clear.frame(height: 44)
            }
            ForEach(days, id: \.self) { date in
                let isPeriod = viewModel.isPeriodDay(date, records: records)
                let isSelected = viewModel.selectedDate != nil && Calendar.current.isDate(viewModel.selectedDate!, inSameDayAs: date)
                let isToday = Calendar.current.isDateInToday(date)
                let flowLevel = viewModel.flowLevelForDate(date, logs: logs)

                Button(action: {
                    viewModel.selectedDate = date
                    showLogSheet = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isPeriod ? Color(hex: "E85D75").opacity(0.3) : Color.clear)
                            .stroke(isSelected ? Color(hex: "F2E4BF") : Color.clear, lineWidth: 2)

                        VStack(spacing: 2) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                                .foregroundStyle(isToday ? Color(hex: "F2E4BF") : .white)

                            if isPeriod {
                                HStack(spacing: 2) {
                                    ForEach(0..<(flowLevel ?? 1), id: \.self) { _ in
                                        Circle()
                                            .fill(Color(hex: "E85D75"))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 8)
    }
}
