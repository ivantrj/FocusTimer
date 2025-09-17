import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Int = 0

    let onFinish: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selection) {
                    OnboardingPage(
                        systemImage: "target",
                        title: "Focus with Pomodoro",
                        subtitle: "Work in focused intervals with short breaks. Customize durations to match your rhythm."
                    )
                    .tag(0)

                    OnboardingPage(
                        systemImage: "list.bullet",
                        title: "Pick a Focus",
                        subtitle: "Choose from recent tasks or add a new one to keep your attention on what matters."
                    )
                    .tag(1)

                    OnboardingPage(
                        systemImage: "bell.badge",
                        title: "Stay on Track",
                        subtitle: "Get notified when work or break sessions end. Haptics keep you in the flow."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                HStack(spacing: 12) {
                    if selection < 2 {
                        Button("Skip") {
                            onFinish()
                        }
                        .buttonStyle(.bordered)

                        Button("Next") {
                            withAnimation { selection = min(2, selection + 1) }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            onFinish()
                        } label: {
                            Text("Get Started")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selection > 0 {
                        Button("Back") {
                            withAnimation { selection = max(0, selection - 1) }
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

private struct OnboardingPage: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 10)

            Image(systemName: systemImage)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 80, weight: .semibold))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Small visual hint for swiping
            HStack(spacing: 6) {
                Image(systemName: "hand.draw")
                    .foregroundStyle(.secondary)
                Text("Swipe to continue")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 10)
        }
        .padding()
    }
}

#Preview {
    OnboardingView {
        // no-op
    }
}
