import SwiftUI

struct PinSetupView: View {
    @State private var viewModel = PinViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "1A1A3E").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text(setupTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(setupSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                PinDotsView(pin: viewModel.enteredPin, showError: viewModel.showError)

                PinPadView(
                    onDigit: { viewModel.addDigit($0) },
                    onDelete: { viewModel.deleteDigit() },
                    onBiometric: nil,
                    biometricIcon: "faceid"
                )

                Spacer()
            }
            .onChange(of: viewModel.isUnlocked) { _, unlocked in
                if unlocked { onComplete() }
            }
            .onAppear {
                viewModel.isSetupMode = true
            }
        }
    }

    private var setupTitle: String {
        switch viewModel.setupStep {
        case .realPin: return "Create Your PIN"
        case .confirmRealPin: return "Confirm Your PIN"
        case .stealthPin: return "Create Stealth PIN"
        case .confirmStealthPin: return "Confirm Stealth PIN"
        }
    }

    private var setupSubtitle: String {
        switch viewModel.setupStep {
        case .realPin: return "This PIN unlocks SafeCycle and shows your real data."
        case .confirmRealPin: return "Enter your PIN again to confirm."
        case .stealthPin: return "This PIN opens a fake calculator. Use it when someone watches you unlock."
        case .confirmStealthPin: return "Enter your stealth PIN again to confirm."
        }
    }
}
