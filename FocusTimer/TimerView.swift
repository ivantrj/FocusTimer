import SwiftUI
import Combine

struct TimerView: View {
    @EnvironmentObject private var settings: PomodoroSettings
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject private var vm: FocusTimerViewModel

    @State private var showTaskPicker = false
    @State private var newTaskTitle: String = ""

    private var formattedRemaining: String {
        let totalSeconds = max(0, Int(vm.remaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Current focus/task
            VStack(spacing: 4) {
                Text("Current Focus")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    showTaskPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                        Text(vm.currentTask?.title ?? "Set a focus")
                            .font(.headline)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
            }

            // Circular progress ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: CGFloat(vm.progress))
                    .stroke(vm.phase == .work ? Color.accentColor : Color.green, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: vm.progress)

                VStack(spacing: 8) {
                    Text(vm.phase.title)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(formattedRemaining)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    if let total = vm.currentPhaseTotal {
                        Text("of \(formatTime(total))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 260, height: 260)
            .padding(.top, 8)

            // Controls
            HStack(spacing: 16) {
                Button {
                    vm.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .labelStyle(.iconOnly)
                        .frame(width: 56, height: 56)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .disabled(!vm.canReset)
                .accessibilityLabel("Reset")

                Button {
                    vm.toggle()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.title3.bold())
                        Text(vm.isRunning ? "Pause" : "Start")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(vm.phase == .work ? Color.accentColor : Color.green, in: Capsule())
                    .foregroundStyle(.white)
                    .shadow(color: (vm.phase == .work ? Color.accentColor : Color.green).opacity(0.35), radius: 10, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(vm.isRunning ? "Pause timer" : "Start timer")

                Button {
                    vm.skipPhase()
                } label: {
                    Label("Skip", systemImage: "forward.end.fill")
                        .labelStyle(.iconOnly)
                        .frame(width: 56, height: 56)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Skip phase")
            }
            .padding(.horizontal)

            // Quick settings summary
            VStack(spacing: 4) {
                Text("Pomodoro")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(settings.workMinutes) min work • \(settings.breakMinutes) min break")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(newTaskTitle: $newTaskTitle)
        }
        .onAppear {
            vm.ensureInitialized()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct TaskPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject private var vm: FocusTimerViewModel

    @Binding var newTaskTitle: String

    var body: some View {
        NavigationStack {
            VStack {
                // Add new task
                HStack(spacing: 12) {
                    TextField("New task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !title.isEmpty else { return }
                        let task = persistence.addTask(title: title)
                        vm.setCurrentTask(task)
                        newTaskTitle = ""
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                // Recent tasks
                if persistence.tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "text.badge.plus", description: Text("Add a task to focus on it."))
                        .padding(.top, 32)
                } else {
                    List {
                        Section("Recent") {
                            ForEach(persistence.tasks) { task in
                                Button {
                                    vm.setCurrentTask(task)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "circle.dashed.inset.filled")
                                            .foregroundStyle(.secondary)
                                        Text(task.title)
                                        Spacer()
                                        if vm.currentTask?.id == task.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.tint)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                persistence.deleteTasks(at: indexSet)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Choose Focus")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
