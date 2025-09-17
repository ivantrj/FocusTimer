import SwiftUI

struct BreathingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Breathing")
                .font(.title.bold())
            Text("A calming breathing exercise will live here. For now, this is a placeholder.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    NavigationStack {
        BreathingView()
            .navigationTitle("Breathing")
    }
}
