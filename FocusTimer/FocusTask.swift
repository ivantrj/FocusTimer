import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var lastUsed: Date

    init(id: UUID = UUID(), title: String, lastUsed: Date = Date()) {
        self.id = id
        self.title = title
        self.lastUsed = lastUsed
    }
}
