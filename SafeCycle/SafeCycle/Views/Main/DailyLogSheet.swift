import SwiftUI
import SwiftData

struct DailyLogSheet: View {
    let date: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var logs: [DailyLog]
    @State private var viewModel = LogViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    periodToggleSection
                    flowSection
                    moodSection
                    painSection
                    energySection
                    sleepSection
                    digestionSection
                    skinSection
                    notesSection
                }
                .padding()
            }
            .background(Color(hex: "0F0F23"))
            .navigationTitle(dateFormatted)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(hex: "F2E4BF"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveLog(for: date, modelContext: modelContext, encryptionKey: nil)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F2E4BF"))
                }
            }
            .onAppear {
                viewModel.loadLog(for: date, logs: logs, encryptionKey: nil)
            }
        }
    }

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private var periodToggleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Period Day")
                .font(.headline)
                .foregroundStyle(.white)
            Toggle("Mark as period day", isOn: $viewModel.isPeriodDay)
                .tint(Color(hex: "E85D75"))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flow")
                .font(.headline)
                .foregroundStyle(.white)
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { level in
                    Button(action: { viewModel.flowLevel = viewModel.flowLevel == level ? nil : level }) {
                        VStack(spacing: 4) {
                            Text(flowEmoji(level))
                                .font(.title2)
                            Text(flowLabel(level))
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(viewModel.flowLevel == level ? Color(hex: "E85D75").opacity(0.3) : Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private func flowEmoji(_ level: Int) -> String {
        switch level {
        case 1: return "💧"
        case 2: return "💧💧"
        case 3: return "💧💧💧"
        default: return "🌊"
        }
    }

    private func flowLabel(_ level: Int) -> String {
        switch level {
        case 1: return "Light"
        case 2: return "Medium"
        case 3: return "Heavy"
        default: return "Very Heavy"
        }
    }

    private var moodSection: some View {
        tagSelectionSection(title: "Mood", options: viewModel.moodOptions, selection: $viewModel.selectedMoods)
    }

    private var painSection: some View {
        tagSelectionSection(title: "Pain", options: viewModel.painOptions, selection: $viewModel.selectedPains)
    }

    private var energySection: some View {
        tagSelectionSection(title: "Energy", options: viewModel.energyOptions, selection: $viewModel.selectedEnergies)
    }

    private var sleepSection: some View {
        tagSelectionSection(title: "Sleep", options: viewModel.sleepOptions, selection: $viewModel.selectedSleeps)
    }

    private var digestionSection: some View {
        tagSelectionSection(title: "Digestion", options: viewModel.digestionOptions, selection: $viewModel.selectedDigestions)
    }

    private var skinSection: some View {
        tagSelectionSection(title: "Skin", options: viewModel.skinOptions, selection: $viewModel.selectedSkins)
    }

    private func tagSelectionSection(title: String, options: [String], selection: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selection.wrappedValue.contains(option) {
                            selection.wrappedValue.remove(option)
                        } else {
                            selection.wrappedValue.insert(option)
                        }
                    }) {
                        Text(option)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selection.wrappedValue.contains(option) ? Color(hex: "F2E4BF").opacity(0.3) : Color.white.opacity(0.05))
                            .foregroundStyle(selection.wrappedValue.contains(option) ? Color(hex: "F2E4BF") : .white.opacity(0.7))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .foregroundStyle(.white)
            TextField("How are you feeling today?", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
    }
}
