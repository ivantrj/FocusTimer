import Foundation

enum PomodoroPhase: String, Codable, CaseIterable, Identifiable {
    case work
    case breakTime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: return "Work"
        case .breakTime: return "Break"
        }
    }
}

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let phase: PomodoroPhase
    let taskTitle: String?
    let start: Date
    let end: Date

    init(id: UUID = UUID(), phase: PomodoroPhase, taskTitle: String?, start: Date, end: Date) {
        self.id = id
        self.phase = phase
        self.taskTitle = taskTitle
        self.start = start
        self.end = end
    }

    var duration: TimeInterval { end.timeIntervalSince(start) }

    var durationText: String {
        let total = Int(duration)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    var dateIntervalText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }
}
