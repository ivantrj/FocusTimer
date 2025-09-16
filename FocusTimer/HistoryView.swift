import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var persistence: Persistence

    var body: some View {
        Group {
            if persistence.history.isEmpty {
                ContentUnavailableView(
                    "No history yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Complete a session to see it here.")
                )
                .padding()
            } else {
                List {
                    Section {
                        ForEach(persistence.history) { session in
                            HistoryRow(session: session)
                        }
                        .onDelete { indexSet in
                            persistence.deleteHistory(at: indexSet)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

private struct HistoryRow: View {
    let session: FocusSession

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            icon
            VStack(alignment: .leading, spacing: 4) {
                Text(session.taskTitle ?? "No task")
                    .font(.headline)
                Text(session.phase.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(session.dateIntervalText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(session.durationText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var icon: some View {
        let isWork = (session.phase == .work)
        return Image(systemName: isWork ? "briefcase.fill" : "cup.and.saucer.fill")
            .foregroundStyle(isWork ? .blue : .green)
    }
}
