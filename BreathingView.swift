import SwiftUI

struct BreathingView: View {
    @State private var selectedTechnique: BreathingTechnique?

    var body: some View {
        List {
            Section("Recommended") {
                TechniqueRow(
                    technique: .calmDown,
                    subtitle: "Use when anxious or stressed. Longer exhales activate relaxation."
                )
                .onTapGesture { selectedTechnique = .calmDown }

                TechniqueRow(
                    technique: .reset,
                    subtitle: "Balanced breathing to recentre. Great between tasks."
                )
                .onTapGesture { selectedTechnique = .reset }
            }

            Section("Boost") {
                TechniqueRow(
                    technique: .energyBoost,
                    subtitle: "Short, even breaths to perk up your energy."
                )
                .onTapGesture { selectedTechnique = .energyBoost }
            }

            Section("Classics") {
                TechniqueRow(
                    technique: .box,
                    subtitle: "Inhale–Hold–Exhale–Hold evenly. Steady and calming."
                )
                .onTapGesture { selectedTechnique = .box }
            }

            Section("Custom") {
                TechniqueRow(
                    technique: .custom,
                    subtitle: "Uses your defaults from Breathing Settings."
                )
                .onTapGesture { selectedTechnique = .custom }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(item: $selectedTechnique) { technique in
            BreathingSessionView(technique: technique)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct TechniqueRow: View {
    let technique: BreathingTechnique
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            icon
            VStack(alignment: .leading, spacing: 6) {
                Text(technique.title)
                    .font(.headline)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }

    private var icon: some View {
        let symbol: String
        let color: Color
        switch technique {
        case .energyBoost:
            symbol = "bolt.fill"; color = .yellow
        case .reset:
            symbol = "arrow.triangle.2.circlepath"; color = .blue
        case .calmDown:
            symbol = "moon.stars.fill"; color = .indigo
        case .box:
            symbol = "square"; color = .teal
        case .custom:
            symbol = "slider.horizontal.3"; color = .orange
        }
        return Image(systemName: symbol)
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
    }
}
