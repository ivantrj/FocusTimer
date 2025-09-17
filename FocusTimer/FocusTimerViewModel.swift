import Foundation
import SwiftUI
import Combine

@MainActor
final class FocusTimerViewModel: ObservableObject {
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var phase: PomodoroPhase = .work
    @Published private(set) var remaining: TimeInterval = 0
    @Published private(set) var progress: Double = 0
    @Published private(set) var currentTask: FocusTask?

    private weak var settings: PomodoroSettings?
    private weak var persistence: Persistence?

    private var totalForPhase: TimeInterval = 0
    private var timerTask: Task<Void, Never>?
    private var phaseStartDate: Date?

    var currentPhaseTotal: Int? {
        guard totalForPhase > 0 else { return nil }
        return Int(totalForPhase)
    }

    func configure(settings: PomodoroSettings, persistence: Persistence) {
        self.settings = settings
        self.persistence = persistence
        applySettings()
    }

    func ensureInitialized() {
        if totalForPhase == 0 {
            applySettings()
        }
    }

    func applySettings() {
        guard let settings else { return }
        let seconds = TimeInterval((phase == .work ? settings.workMinutes : settings.breakMinutes) * 60)
        totalForPhase = seconds
        if !isRunning {
            remaining = seconds
            progress = 0
        } else {
            progress = 1 - (remaining / max(totalForPhase, 0.001))
        }
    }

    func setCurrentTask(_ task: FocusTask?) {
        currentTask = task
        if var t = task {
            t.lastUsed = Date()
            persistence?.updateTask(t)
        }
    }

    var canReset: Bool {
        remaining < totalForPhase || isRunning
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        if remaining <= 0 || totalForPhase == 0 {
            applySettings()
        }
        if phaseStartDate == nil {
            phaseStartDate = Date()
        }
        triggerHaptic(.start)
        scheduleNotificationForCurrentPhase()
        beginTimerLoop()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        triggerHaptic(.pause)
        Task { await NotificationsManager.shared.cancelPhaseNotifications() }
    }

    func reset() {
        pause()
        phaseStartDate = nil
        applySettings()
    }

    func skipPhase() {
        completePhase(skipped: true)
        switchPhase(autoStart: true)
    }

    private func beginTimerLoop() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            var lastTick = Date()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                let now = Date()
                let delta = now.timeIntervalSince(lastTick)
                lastTick = now
                remaining = max(0, remaining - delta)
                progress = min(1, max(0, 1 - (remaining / max(totalForPhase, 0.001))))
                if remaining <= 0 {
                    completePhase(skipped: false)
                    switchPhase(autoStart: true)
                    break
                }
            }
        }
    }

    private func completePhase(skipped: Bool) {
        guard let persistence else { return }
        let end = Date()
        let start = phaseStartDate ?? Date().addingTimeInterval(-totalForPhase)
        phaseStartDate = nil

        Task { await NotificationsManager.shared.cancelPhaseNotifications() }

        if !skipped {
            let session = FocusSession(
                phase: phase,
                taskTitle: currentTask?.title,
                start: start,
                end: end
            )
            persistence.logSession(session)
            triggerHaptic(.success)
        } else {
            triggerHaptic(.skip)
        }
    }

    private func switchPhase(autoStart: Bool) {
        pause()
        guard let settings else { return }
        phase = (phase == .work) ? .breakTime : .work
        totalForPhase = TimeInterval((phase == .work ? settings.workMinutes : settings.breakMinutes) * 60)
        remaining = totalForPhase
        progress = 0
        if autoStart && ((phase == .breakTime && settings.autoStartBreak) || (phase == .work && settings.autoStartWork)) {
            start()
        }
    }

    func resetToDefaults() {
        pause()
        phaseStartDate = nil
        progress = 0
        applySettings()
    }

    // MARK: - Notifications

    private func scheduleNotificationForCurrentPhase() {
        let fireDate = Date().addingTimeInterval(remaining)
        Task {
            await NotificationsManager.shared.schedulePhaseCompletionNotification(
                phase: phase,
                taskTitle: currentTask?.title,
                fireDate: fireDate
            )
        }
    }

    // MARK: - Haptics

    private enum HapticType {
        case start, pause, success, skip
    }

    private func triggerHaptic(_ type: HapticType) {
#if os(iOS)
        switch type {
        case .start:
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        case .pause:
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
        case .success:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        case .skip:
            let gen = UIImpactFeedbackGenerator(style: .rigid)
            gen.impactOccurred()
        }
#endif
    }
}
