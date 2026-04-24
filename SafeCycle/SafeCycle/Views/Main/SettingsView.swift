import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [PeriodRecord]
    @Query private var logs: [DailyLog]
    @State private var viewModel = SettingsViewModel()
    @State private var showExportSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        Form {
            securitySection
            notificationSection
            dataSection
            supportSection
            aboutSection
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: "0F0F23"))
    }

    private var securitySection: some View {
        Section {
            Toggle("Face ID / Touch ID", isOn: Binding(
                get: { viewModel.isFaceIDEnabled },
                set: { viewModel.toggleFaceID($0) }
            ))
            .tint(Color(hex: "7EC8A0"))

            NavigationLink {
                PinChangeView()
            } label: {
                Text("Change PIN")
                    .foregroundStyle(.white)
            }
        } header: {
            Text("Security")
                .foregroundStyle(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var notificationSection: some View {
        Section {
            Toggle("Daily Reminder", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.toggleNotifications($0) }
            ))
            .tint(Color(hex: "7EC8A0"))

            if viewModel.notificationsEnabled {
                DatePicker("Reminder Time", selection: Binding(
                    get: {
                        let calendar = Calendar.current
                        var components = DateComponents()
                        components.hour = viewModel.notificationHour
                        components.minute = viewModel.notificationMinute
                        return calendar.date(from: components) ?? Date()
                    },
                    set: { date in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                        viewModel.updateNotificationTime(hour: components.hour ?? 9, minute: components.minute ?? 0)
                    }
                ), displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Notifications")
                .foregroundStyle(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var dataSection: some View {
        Section {
            Button(action: { showExportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Backup")
                }
                .foregroundStyle(Color(hex: "7EC8A0"))
            }

            Button(role: .destructive, action: { showDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete All Data")
                }
            }
            .alert("Delete All Data?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This action cannot be undone. All your tracked data will be permanently deleted.")
            }
        } header: {
            Text("Data")
                .foregroundStyle(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.white.opacity(0.5))
            }
            HStack {
                Text("Data Storage")
                Spacer()
                Text("100% Local")
                    .foregroundStyle(Color(hex: "7EC8A0"))
            }
            HStack {
                Text("Encryption")
                Spacer()
                Text("AES-256-GCM")
                    .foregroundStyle(Color(hex: "7EC8A0"))
            }
            HStack {
                Text("Network Access")
                Spacer()
                Text("None")
                    .foregroundStyle(Color(hex: "7EC8A0"))
            }
        } header: {
            Text("About")
                .foregroundStyle(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var supportSection: some View {
        Section {
            Link(destination: URL(string: "mailto:support@safecycle.app?subject=SafeCycle%20Feedback")!) {
                HStack {
                    Image(systemName: "envelope")
                    Text("Email Support")
                }
                .foregroundStyle(Color(hex: "F2E4BF"))
            }
            Link(destination: URL(string: "https://safecycle.app/privacy")!) {
                HStack {
                    Image(systemName: "hand.raised")
                    Text("Privacy Policy")
                }
                .foregroundStyle(Color(hex: "F2E4BF"))
            }
            Link(destination: URL(string: "https://safecycle.app/terms")!) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Terms of Use")
                }
                .foregroundStyle(Color(hex: "F2E4BF"))
            }
        } header: {
            Text("Support")
                .foregroundStyle(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private func deleteAllData() {
        do {
            try modelContext.delete(model: PeriodRecord.self)
            try modelContext.delete(model: DailyLog.self)
            try modelContext.save()
        } catch {}
    }
}

struct PinChangeView: View {
    @State private var newPin = ""
    @State private var confirmPin = ""
    @State private var step = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text(step == 0 ? "Enter New PIN" : "Confirm New PIN")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            PinDotsView(pin: step == 0 ? newPin : confirmPin, showError: false)

            PinPadView(
                onDigit: { digit in
                    if step == 0 {
                        guard newPin.count < 4 else { return }
                        newPin += digit
                        if newPin.count == 4 { step = 1 }
                    } else {
                        guard confirmPin.count < 4 else { return }
                        confirmPin += digit
                        if confirmPin.count == 4 && confirmPin == newPin {
                            KeychainHelper.shared.set(key: "real_pin", value: newPin)
                            dismiss()
                        }
                    }
                },
                onDelete: {
                    if step == 0 { if !newPin.isEmpty { newPin.removeLast() } }
                    else { if !confirmPin.isEmpty { confirmPin.removeLast() } else { step = 0 } }
                },
                onBiometric: nil,
                biometricIcon: "faceid"
            )
        }
        .background(Color(hex: "1A1A3E"))
    }
}
