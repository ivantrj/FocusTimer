import SwiftUI

struct HistorySettingsView: View {
    @AppStorage("history.keepCount") private var keepCount: Int = 200
    @AppStorage("history.showBreaks") private var showBreaks: Bool = true
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show Break Sessions", isOn: $showBreaks)
                    Stepper(value: $keepCount, in: 20...2000, step: 20) {
                        HStack {
                            Text("Keep Last")
                            Spacer()
                            Text("\(keepCount)").foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        // Clear all history
                        let count = persistence.history.count
                        persistence.deleteHistory(at: IndexSet(integersIn: 0..<count))
                    } label: {
                        Text("Clear History")
                    }
                } footer: {
                    Text("This will permanently delete all recorded sessions from this device.")
                }
            }
            .navigationTitle("History Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HistorySettingsView()
        .environmentObject(Persistence())
}
