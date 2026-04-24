import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
    @Query private var records: [PeriodRecord]
    @Query private var logs: [DailyLog]
    @State private var viewModel = ChartsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                timeRangePicker
                cycleLengthChart
                symptomFrequencyChart
                statsSummary
            }
            .padding()
        }
        .background(Color(hex: "0F0F23"))
        .onAppear {
            viewModel.updateData(records: records, logs: logs)
        }
        .onChange(of: records.count) { _, _ in
            viewModel.updateData(records: records, logs: logs)
        }
    }

    private var timeRangePicker: some View {
        HStack {
            ForEach(ChartsViewModel.TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    viewModel.selectedTimeRange = range
                    viewModel.updateData(records: records, logs: logs)
                }) {
                    Text(range.rawValue)
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedTimeRange == range ? .semibold : .regular)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedTimeRange == range ? Color(hex: "F2E4BF").opacity(0.3) : Color.clear)
                        .foregroundStyle(viewModel.selectedTimeRange == range ? Color(hex: "F2E4BF") : .white.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.05))
        .clipShape(Capsule())
    }

    private var cycleLengthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cycle Length")
                .font(.headline)
                .foregroundStyle(.white)

            if viewModel.cycleLengths.isEmpty {
                Text("Not enough data yet. Track at least 2 cycles.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart {
                    ForEach(Array(viewModel.cycleLengths.enumerated()), id: \.offset) { index, length in
                        BarMark(
                            x: .value("Cycle", index + 1),
                            y: .value("Days", length)
                        )
                        .foregroundStyle(Color(hex: "7EC8A0").gradient)
                        .cornerRadius(4)
                    }
                    RuleMark(y: .value("Average", viewModel.cycleLengths.reduce(0, +) / Double(viewModel.cycleLengths.count)))
                        .foregroundStyle(Color(hex: "F2E4BF").opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(height: 180)
                .chartYScale(domain: 20...40)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private var symptomFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptom Tracking")
                .font(.headline)
                .foregroundStyle(.white)

            if viewModel.symptomFrequencies.isEmpty {
                Text("Start logging daily symptoms to see trends.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart {
                    ForEach(Array(viewModel.symptomFrequencies.sorted { $0.value > $1.value }), id: \.key) { symptom, count in
                        BarMark(
                            x: .value("Symptom", symptom),
                            y: .value("Days", count)
                        )
                        .foregroundStyle(Color(hex: "8B7EB8").gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private var statsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(.white)

            let avgCycle = viewModel.cycleLengths.isEmpty ? 0 : viewModel.cycleLengths.reduce(0, +) / Double(viewModel.cycleLengths.count)
            let shortest = viewModel.cycleLengths.map { Int($0) }.min() ?? 0
            let longest = viewModel.cycleLengths.map { Int($0) }.max() ?? 0

            HStack(spacing: 16) {
                statItem(title: "Avg Cycle", value: "\(Int(avgCycle))d")
                statItem(title: "Shortest", value: "\(shortest)d")
                statItem(title: "Longest", value: "\(longest)d")
                statItem(title: "Total", value: "\(records.count)")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
