import SwiftUI

struct BreathingSessionView: View {
    let technique: BreathingTechnique
    @StateObject private var vm = BreathingViewModel()

    // Animated circle scale
    @State private var circleScale: CGFloat = 0.8
    @State private var phaseTextScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 4) {
                Text(technique.title)
                    .font(.headline)
                Text(technique.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Animated breathing circle
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 220, height: 220)
                    .scaleEffect(circleScale)
                    .shadow(color: gradientColors.first?.opacity(0.25) ?? .blue.opacity(0.25), radius: 20, y: 10)
                    .animation(.easeInOut(duration: animationDuration), value: circleScale)

                VStack(spacing: 8) {
                    Text(vm.currentPhase.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .scaleEffect(phaseTextScale)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: phaseTextScale)

                    Text(String(format: "%02d", vm.secondsRemaining))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)

                    Text("Cycle \(vm.cycleDisplay)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)

            // Guidance text
            Text(guidanceText(for: vm.currentPhase))
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

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
                .accessibilityLabel("Reset")

                Button {
                    vm.isRunning ? vm.pause() : vm.start()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.title3.bold())
                        Text(vm.isRunning ? "Pause" : "Start")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor, in: Capsule())
                    .foregroundStyle(.white)
                    .shadow(color: Color.accentColor.opacity(0.35), radius: 10, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(vm.isRunning ? "Pause breathing" : "Start breathing")

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

            Spacer()
        }
        .padding()
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.selectTechnique(technique)
            applyPhaseAnimation(for: vm.currentPhase)
        }
        .onChange(of: vm.currentPhase) { _, newPhase in
            pulsePhaseText()
            applyPhaseAnimation(for: newPhase)
        }
    }

    // MARK: - Animation helpers

    private func applyPhaseAnimation(for phase: BreathingPhase) {
        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: animationDuration)) {
                circleScale = 1.15
            }
        case .hold:
            withAnimation(.easeInOut(duration: 0.2)) {
                circleScale = 1.15
            }
        case .exhale:
            withAnimation(.easeInOut(duration: animationDuration)) {
                circleScale = 0.8
            }
        }
    }

    private func pulsePhaseText() {
        phaseTextScale = 1.12
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                phaseTextScale = 1.0
            }
        }
    }

    private var animationDuration: Double {
        // Make animation proportional-ish to remaining seconds for a smoother feel
        max(0.6, min(1.2, Double(max(1, vm.secondsRemaining)) * 0.25))
    }

    private var gradientColors: [Color] {
        switch technique {
        case .energyBoost: return [.yellow, .orange]
        case .reset: return [.blue, .teal]
        case .calmDown: return [.indigo, .purple]
        case .box: return [.teal, .green]
        case .custom: return [.orange, .pink]
        }
    }

    private func guidanceText(for phase: BreathingPhase) -> String {
        switch phase {
        case .inhale: return "Breathe in gently through your nose."
        case .hold: return "Hold your breath softly."
        case .exhale: return "Exhale slowly through your mouth."
        }
    }
}

#Preview {
    NavigationStack {
        BreathingSessionView(technique: .calmDown)
    }
}
