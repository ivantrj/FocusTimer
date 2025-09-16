import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: PomodoroSettings
    @EnvironmentObject private var vm: FocusTimerViewModel

    @State private var work: Int = 25
    @State private var brk: Int = 5
    @State private var autoStartBreak = true
    @State private var autoStartWork = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Durations (minutes)") {
                    Stepper(value: $work, in: 5...120, step: 1) {
                        HStack {
                            Text("Work")
                            Spacer()
                            Text("\(work) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $brk, in: 1...60, step: 1) {
                        HStack {
                            Text("Break")
                            Spacer()
                            Text("\(brk) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Behavior") {
                    Toggle("Auto-start break", isOn: $autoStartBreak)
                    Toggle("Auto-start next work", isOn: $autoStartWork)
                }

                Section {
                    Button(role: .destructive) {
                        vm.resetToDefaults()
                    } label: {
                        Text("Reset Timer")
                    }
                } footer: {
                    Text("Resets the current countdown and phase.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                work = settings.workMinutes
                brk = settings.breakMinutes
                autoStartBreak = settings.autoStartBreak
                autoStartWork = settings.autoStartWork
            }
            .onChange(of: work) { _, newValue in
                settings.workMinutes = newValue
                vm.applySettings()
            }
            .onChange(of: brk) { _, newValue in
                settings.breakMinutes = newValue
                vm.applySettings()
            }
            .onChange(of: autoStartBreak) { _, newValue in
                settings.autoStartBreak = newValue
            }
            .onChange(of: autoStartWork) { _, newValue in
                settings.autoStartWork = newValue
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}
