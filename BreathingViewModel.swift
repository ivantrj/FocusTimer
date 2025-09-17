import Foundation
import SwiftUI
import Combine

@MainActor
final class BreathingViewModel: ObservableObject {
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var currentPhase: BreathingPhase = .inhale
    @Published private(set) var secondsRemaining: Int = 0
    @Published private(set) var cycleIndex: Int = 0 // 0-based
    @Published private(set) var selectedTechnique: BreathingTechnique = .custom
    @Published private(set) var pattern: BreathingPattern = BreathingPattern(inhale: 4, hold: 4, exhale: 4, cycles: 6)

    // Settings defaults
    @AppStorage("breathing.inhaleSeconds") private var defaultInhale: Int = 4
    @AppStorage("breathing.holdSeconds") private var defaultHold: Int = 4
    @AppStorage("breathing.exhaleSeconds") private var defaultExhale: Int = 4
    @AppStorage("breathing.cycles") private var defaultCycles: Int = 6
    @AppStorage("breathing.haptics") private var breathingHaptics: Bool = true

    private var timerTask: Task<Void, Never>?

    init() {
        // Read current defaults via the property wrappers (self is already fully initialized now)
        let inhale = defaultInhale
        let hold = defaultHold
        let exhale = defaultExhale
        let cycles = defaultCycles

        let defaults = BreathingPattern(inhale: inhale, hold: hold, exhale: exhale, cycles: cycles)
        self.pattern = BreathingTechnique.custom.pattern(defaults: defaults)
        reset(to: selectedTechnique)
    }

    func updateDefaultsFromSettings() {
        let defaults = BreathingPattern(inhale: defaultInhale, hold: defaultHold, exhale: defaultExhale, cycles: defaultCycles)
        if selectedTechnique == .custom {
            pattern = defaults
            preparePhase(.inhale)
        }
    }

    func selectTechnique(_ technique: BreathingTechnique) {
        selectedTechnique = technique
        let defaults = BreathingPattern(inhale: defaultInhale, hold: defaultHold, exhale: defaultExhale, cycles: defaultCycles)
        pattern = technique.pattern(defaults: defaults)
        reset(to: technique)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        if secondsRemaining <= 0 {
            preparePhase(.inhale)
        }
        runTimer()
        triggerHaptic(for: currentPhase)
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        // gentle haptic
        if breathingHaptics { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }

    func reset(to technique: BreathingTechnique? = nil) {
        pause()
        cycleIndex = 0
        preparePhase(.inhale)
    }

    func skipPhase() {
        advancePhase()
    }

    private func preparePhase(_ phase: BreathingPhase) {
        currentPhase = phase
        switch phase {
        case .inhale: secondsRemaining = max(1, pattern.inhale)
        case .hold: secondsRemaining = max(0, pattern.hold)
        case .exhale: secondsRemaining = max(1, pattern.exhale)
        }
    }

    private func advancePhase() {
        switch currentPhase {
        case .inhale:
            if pattern.hold > 0 {
                preparePhase(.hold)
            } else {
                preparePhase(.exhale)
            }
        case .hold:
            preparePhase(.exhale)
        case .exhale:
            // cycle finished
            if cycleIndex + 1 < pattern.cycles {
                cycleIndex += 1
                preparePhase(.inhale)
            } else {
                // done
                completeAllCycles()
                return
            }
        }
        triggerHaptic(for: currentPhase)
    }

    private func completeAllCycles() {
        pause()
        // success haptic
        if breathingHaptics {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func runTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && isRunning {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard isRunning else { break }
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                }
                if secondsRemaining <= 0 {
                    advancePhase()
                }
            }
        }
    }

    private func triggerHaptic(for phase: BreathingPhase) {
        guard breathingHaptics else { return }
        switch phase {
        case .inhale:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .hold:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .exhale:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    // Progress helpers
    var cycleDisplay: String {
        "\(cycleIndex + 1)/\(max(1, pattern.cycles))"
    }

    func progressForPhase() -> Double {
        let total: Double
        let elapsed: Double
        switch currentPhase {
        case .inhale:
            total = Double(max(1, pattern.inhale))
            elapsed = total - Double(secondsRemaining)
        case .hold:
            total = Double(max(1, pattern.hold))
            elapsed = total - Double(secondsRemaining)
        case .exhale:
            total = Double(max(1, pattern.exhale))
            elapsed = total - Double(secondsRemaining)
        }
        guard total > 0 else { return 1 }
        return min(1, max(0, elapsed / total))
    }
}
