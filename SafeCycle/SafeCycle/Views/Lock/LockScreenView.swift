import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @State private var viewModel = PinViewModel()
    @State private var useFaceID = false
    let onUnlock: (Bool) -> Void

    var body: some View {
        ZStack {
            Color(hex: "1A1A3E").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "F2E4BF"))

                Text("SafeCycle")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("Enter PIN to unlock")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                PinDotsView(pin: viewModel.enteredPin, showError: viewModel.showError)

                PinPadView(
                    onDigit: { viewModel.addDigit($0) },
                    onDelete: { viewModel.deleteDigit() },
                    onBiometric: useFaceID ? { authenticateBiometric() } : nil,
                    biometricIcon: "faceid"
                )

                Spacer()
            }
            .onChange(of: viewModel.isUnlocked) { _, unlocked in
                if unlocked {
                    onUnlock(viewModel.isStealthMode)
                }
            }
            .onAppear {
                useFaceID = UserDefaults.standard.bool(forKey: "face_id_enabled")
                if useFaceID && !viewModel.hasPinSet {
                    authenticateBiometric()
                }
            }
        }
    }

    private func authenticateBiometric() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return }
        Task {
            let success = await DashboardViewModel().authenticateWithBiometrics()
            if success {
                await MainActor.run {
                    viewModel.isUnlocked = true
                    viewModel.isStealthMode = false
                }
            }
        }
    }
}

struct PinDotsView: View {
    let pin: String
    let showError: Bool

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index < pin.count ? Color(hex: "F2E4BF") : Color.clear)
                    .stroke(Color(hex: "F2E4BF"), lineWidth: 2)
                    .frame(width: 16, height: 16)
                    .scaleEffect(showError ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showError)
            }
        }
    }
}

struct PinPadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onBiometric: (() -> Void)?
    let biometricIcon: String

    var body: some View {
        VStack(spacing: 16) {
            ForEach(["123", "456", "789"], id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(Array(row), id: \.self) { digit in
                        PinButton(digit: String(digit)) { onDigit(String(digit)) }
                    }
                }
            }
            HStack(spacing: 24) {
                if let biometric = onBiometric {
                    Button(action: biometric) {
                        Image(systemName: biometricIcon)
                            .font(.title2)
                            .foregroundStyle(Color(hex: "F2E4BF"))
                            .frame(width: 72, height: 72)
                    }
                } else {
                    Color.clear.frame(width: 72, height: 72)
                }
                PinButton(digit: "0") { onDigit("0") }
                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                }
            }
        }
    }
}

struct PinButton: View {
    let digit: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(digit)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
    }
}
