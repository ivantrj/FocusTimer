import Foundation

enum BreathingPhase: String, Codable, CaseIterable, Identifiable {
    case inhale
    case hold
    case exhale

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        }
    }

    var symbol: String {
        switch self {
        case .inhale: return "arrow.down.circle"
        case .hold: return "pause.circle"
        case .exhale: return "arrow.up.circle"
        }
    }
}

struct BreathingPattern: Equatable, Codable {
    var inhale: Int
    var hold: Int
    var exhale: Int
    var cycles: Int

    var totalSecondsPerCycle: Int { inhale + hold + exhale }
}

enum BreathingTechnique: String, CaseIterable, Identifiable, Codable {
    case energyBoost
    case reset
    case calmDown
    case box
    case custom // uses settings defaults

    var id: String { rawValue }

    var title: String {
        switch self {
        case .energyBoost: return "Energy Boost"
        case .reset: return "Reset"
        case .calmDown: return "Calm Down"
        case .box: return "Box Breathing"
        case .custom: return "Custom"
        }
    }

    var description: String {
        switch self {
        case .energyBoost: return "Quick pick-me-up. Short exhales."
        case .reset: return "Balanced reset. Even breaths."
        case .calmDown: return "Long exhales to relax."
        case .box: return "Inhale–Hold–Exhale–Hold evenly."
        case .custom: return "Uses your default settings."
        }
    }

    func pattern(defaults: BreathingPattern) -> BreathingPattern {
        switch self {
        case .energyBoost:
            return BreathingPattern(inhale: 3, hold: 2, exhale: 3, cycles: 6)
        case .reset:
            return BreathingPattern(inhale: 4, hold: 2, exhale: 4, cycles: 8)
        case .calmDown:
            return BreathingPattern(inhale: 4, hold: 2, exhale: 6, cycles: 6)
        case .box:
            return BreathingPattern(inhale: 4, hold: 4, exhale: 4, cycles: 6)
        case .custom:
            return defaults
        }
    }
}
