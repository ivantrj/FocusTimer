import Foundation
import Combine
import SwiftUI

@MainActor
final class Persistence: ObservableObject {
    @Published private(set) var tasks: [FocusTask] = []
    @Published private(set) var history: [FocusSession] = []

    private let tasksKey = "persistence.tasks"
    private let historyKey = "persistence.history"

    init() {
        load()
    }

    func load() {
        tasks = loadArray(FocusTask.self, key: tasksKey)
            .sorted { $0.lastUsed > $1.lastUsed }
        history = loadArray(FocusSession.self, key: historyKey)
            .sorted { $0.start > $1.start }
    }

    func addTask(title: String) -> FocusTask {
        let existing = tasks.first { $0.title.caseInsensitiveCompare(title) == .orderedSame }
        if var task = existing {
            task.lastUsed = Date()
            updateTask(task)
            return task
        } else {
            let task = FocusTask(title: title, lastUsed: Date())
            tasks.insert(task, at: 0)
            saveArray(tasks, key: tasksKey)
            return task
        }
    }

    func updateTask(_ task: FocusTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
        } else {
            tasks.insert(task, at: 0)
        }
        tasks.sort { $0.lastUsed > $1.lastUsed }
        saveArray(tasks, key: tasksKey)
    }

    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveArray(tasks, key: tasksKey)
    }

    func logSession(_ session: FocusSession) {
        history.insert(session, at: 0)
        saveArray(history, key: historyKey)
        if let title = session.taskTitle {
            var task = addTask(title: title)
            task.lastUsed = Date()
            updateTask(task)
        }
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveArray(history, key: historyKey)
    }

    private func loadArray<T: Decodable>(_ type: T.Type, key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            return []
        }
    }

    private func saveArray<T: Encodable>(_ array: [T], key: String) {
        do {
            let data = try JSONEncoder().encode(array)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // Ignore errors in v1
        }
    }
}
