import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodRecord.startDate, order: .reverse) private var records: [PeriodRecord]
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                phaseCard
                nextPeriodCard
                cycleInfoCard
                quickLogButton
            }
            .padding()
        }
        .background(Color(hex: "0F0F23"))
        .onAppear {
            viewModel.updateFromRecords(records)
        }
        .onChange(of: records.count) { _, _ in
            viewModel.updateFromRecords(records)
        }
    }

    private var phaseCard: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentPhase.emoji)
                .font(.system(size: 48))
            Text(viewModel.currentPhase.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Text(viewModel.currentPhase.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Text("Day \(viewModel.cycleDay)")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: viewModel.currentPhase.colorHex).opacity(0.3))
                .clipShape(Capsule())
                .foregroundStyle(Color(hex: viewModel.currentPhase.colorHex))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: viewModel.currentPhase.colorHex).opacity(0.3), lineWidth: 1)
        )
    }

    private var nextPeriodCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Period")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Text(viewModel.daysUntilNextPeriod == 0 ? "Today" : "In \(viewModel.daysUntilNextPeriod) days")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Confidence")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(Int(viewModel.confidence * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "7EC8A0"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }

    private var cycleInfoCard: some View {
        HStack(spacing: 16) {
            cycleInfoItem(title: "Avg Cycle", value: "\(Int(viewModel.averageCycleLength)) days")
            Divider().foregroundStyle(.white.opacity(0.2))
            cycleInfoItem(title: "Avg Period", value: "\(Int(viewModel.averagePeriodLength)) days")
            Divider().foregroundStyle(.white.opacity(0.2))
            cycleInfoItem(title: "Tracked", value: "\(records.count) cycles")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func cycleInfoItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickLogButton: some View {
        Button(action: {
            let record = PeriodRecord(startDate: Date())
            modelContext.insert(record)
            try? modelContext.save()
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Log Period Start")
            }
            .font(.headline)
            .foregroundStyle(Color(hex: "1A1A3E"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "E85D75"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
