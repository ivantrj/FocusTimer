import SwiftUI

struct BreathingSettingsView: View {
    @AppStorage("breathing.inhaleSeconds") private var inhaleSeconds: Int = 4
    @AppStorage("breathing.holdSeconds") private var holdSeconds: Int = 4
    @AppStorage("breathing.exhaleSeconds") private var exhaleSeconds: Int = 4
    @AppStorage("breathing.cycles") private var cycles: Int = 6
    @AppStorage("breathing.haptics") private var breathingHaptics: Bool = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Default Technique") {
                    Stepper(value: $inhaleSeconds, in: 1...12) {
                        HStack {
                            Text("Inhale")
                            Spacer()
                            Text("\(inhaleSeconds) s").foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $holdSeconds, in: 0...12) {
                        HStack {
                            Text("Hold")
                            Spacer()
                            Text("\(holdSeconds) s").foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $exhaleSeconds, in: 1...12) {
                        HStack {
                            Text("Exhale")
                            Spacer()
                            Text("\(exhaleSeconds) s").foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $cycles, in: 1...20) {
                        HStack {
                            Text("Cycles")
                            Spacer()
                            Text("\(cycles)").foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Feedback") {
                    Toggle("Haptics", isOn: $breathingHaptics)
                }

                Section {
                    Button(role: .destructive) {
                        inhaleSeconds = 4
                        holdSeconds = 4
                        exhaleSeconds = 4
                        cycles = 6
                        breathingHaptics = true
                    } label: {
                        Text("Reset Defaults")
                    }
                }
            }
            .navigationTitle("Breathing Settings")
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
    BreathingSettingsView()
}
