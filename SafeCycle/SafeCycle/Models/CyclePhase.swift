import Foundation

enum CyclePhase: String, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulation = "Ovulation"
    case luteal = "Luteal"

    var emoji: String {
        switch self {
        case .menstrual: return "🩸"
        case .follicular: return "🌱"
        case .ovulation: return "🌸"
        case .luteal: return "🌙"
        }
    }

    var colorHex: String {
        switch self {
        case .menstrual: return "#E85D75"
        case .follicular: return "#7EC8A0"
        case .ovulation: return "#F4A261"
        case .luteal: return "#8B7EB8"
        }
    }

    var description: String {
        switch self {
        case .menstrual: return "Your period phase. Rest and self-care."
        case .follicular: return "Energy rises. Great time for new projects."
        case .ovulation: return "Peak energy and fertility window."
        case .luteal: return "Winding down. Listen to your body."
        }
    }

    static func from(cycleDay: Int, avgCycleLength: Double) -> CyclePhase {
        let ovulationDay = Int(avgCycleLength) - 14
        switch cycleDay {
        case 1...5:
            return .menstrual
        case 6..<ovulationDay:
            return .follicular
        case (ovulationDay - 2)...(ovulationDay + 2):
            return .ovulation
        default:
            return .luteal
        }
    }
}
