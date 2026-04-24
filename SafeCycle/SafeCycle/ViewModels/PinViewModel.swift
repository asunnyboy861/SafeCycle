import SwiftUI

@Observable
final class PinViewModel {
    var enteredPin: String = ""
    var isStealthMode: Bool = false
    var isUnlocked: Bool = false
    var showError: Bool = false
    var isSetupMode: Bool = false
    var setupStep: SetupStep = .realPin
    var confirmPin: String = ""

    enum SetupStep {
        case realPin
        case confirmRealPin
        case stealthPin
        case confirmStealthPin
    }

    var realPin: String {
        KeychainHelper.shared.get(key: "real_pin") ?? ""
    }

    var stealthPin: String {
        KeychainHelper.shared.get(key: "stealth_pin") ?? ""
    }

    var hasPinSet: Bool {
        !realPin.isEmpty
    }

    func verifyPin() {
        if enteredPin == realPin {
            isStealthMode = false
            isUnlocked = true
            showError = false
        } else if enteredPin == stealthPin && !stealthPin.isEmpty {
            isStealthMode = true
            isUnlocked = true
            showError = false
        } else {
            showError = true
        }
        enteredPin = ""
    }

    func addDigit(_ digit: String) {
        guard enteredPin.count < 4 else { return }
        enteredPin += digit
        if enteredPin.count == 4 {
            if isSetupMode {
                handleSetupPin()
            } else {
                verifyPin()
            }
        }
    }

    func deleteDigit() {
        if !enteredPin.isEmpty {
            enteredPin.removeLast()
        }
        showError = false
    }

    private func handleSetupPin() {
        switch setupStep {
        case .realPin:
            confirmPin = enteredPin
            enteredPin = ""
            setupStep = .confirmRealPin
        case .confirmRealPin:
            if enteredPin == confirmPin {
                KeychainHelper.shared.set(key: "real_pin", value: enteredPin)
                enteredPin = ""
                confirmPin = ""
                setupStep = .stealthPin
            } else {
                showError = true
                enteredPin = ""
                setupStep = .realPin
            }
        case .stealthPin:
            confirmPin = enteredPin
            enteredPin = ""
            setupStep = .confirmStealthPin
        case .confirmStealthPin:
            if enteredPin == confirmPin {
                KeychainHelper.shared.set(key: "stealth_pin", value: enteredPin)
                isUnlocked = true
            } else {
                showError = true
                enteredPin = ""
                setupStep = .stealthPin
            }
        }
    }
}
