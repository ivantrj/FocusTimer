import SwiftUI
import Combine

final class PomodoroSettings: ObservableObject {
    @AppStorage("workMinutes") var workMinutes: Int = 25 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("breakMinutes") var breakMinutes: Int = 5 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("autoStartBreak") var autoStartBreak: Bool = true {
        didSet { objectWillChange.send() }
    }
    @AppStorage("autoStartWork") var autoStartWork: Bool = false {
        didSet { objectWillChange.send() }
    }
}
