import SwiftUI

struct CalculatorStealthView: View {
    @State private var display = "0"
    @State private var previousValue: Double?
    @State private var operation: String?
    @State private var shouldResetDisplay = false

    var body: some View {
        VStack(spacing: 12) {
            Text(display)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
                .padding(.top, 40)

            Spacer()

            let buttons = [
                ["AC", "±", "%", "÷"],
                ["7", "8", "9", "×"],
                ["4", "5", "6", "−"],
                ["1", "2", "3", "+"],
                ["0", "", ".", "="]
            ]

            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        if button.isEmpty {
                            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity).frame(height: 72)
                        } else {
                            Button(action: { calculatorTap(button) }) {
                                Text(button)
                                    .font(.system(size: 28, weight: .medium))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(buttonColor(button))
                                    .foregroundStyle(.white)
                                    .clipShape(button == "0" ? AnyShape(RoundedRectangle(cornerRadius: 24)) : AnyShape(Circle()))
                            }
                            .frame(height: 72)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }

    private func calculatorTap(_ button: String) {
        switch button {
        case "AC":
            display = "0"
            previousValue = nil
            operation = nil
            shouldResetDisplay = false
        case "±":
            if let val = Double(display) { display = formatNumber(-val) }
        case "%":
            if let val = Double(display) { display = formatNumber(val / 100) }
        case "÷", "×", "−", "+":
            previousValue = Double(display)
            operation = button
            shouldResetDisplay = true
        case "=":
            if let prev = previousValue, let current = Double(display), let op = operation {
                let result: Double
                switch op {
                case "÷": result = current != 0 ? prev / current : 0
                case "×": result = prev * current
                case "−": result = prev - current
                case "+": result = prev + current
                default: result = current
                }
                display = formatNumber(result)
                previousValue = nil
                operation = nil
                shouldResetDisplay = false
            }
        case ".":
            if shouldResetDisplay { display = "0."; shouldResetDisplay = false; return }
            if !display.contains(".") { display += "." }
        default:
            if shouldResetDisplay || display == "0" {
                display = button
                shouldResetDisplay = false
            } else {
                display += button
            }
        }
    }

    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(format: "%.8g", value)
    }

    private func buttonColor(_ button: String) -> Color {
        if ["÷", "×", "−", "+", "="].contains(button) { return .orange }
        if ["AC", "±", "%"].contains(button) { return Color.gray.opacity(0.8) }
        return Color.gray.opacity(0.3)
    }
}

struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { _path = { rect in shape.path(in: rect) } }
    func path(in rect: CGRect) -> Path { _path(rect) }
}
