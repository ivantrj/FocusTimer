//
//  ContentView.swift
//  FocusTimer
//
//  Created by Ivan Trajanovski  on 16.09.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = PomodoroSettings()
    @StateObject private var persistence = Persistence()
    @StateObject private var timerVM = FocusTimerViewModel()

    // Per-tab settings sheets
    @State private var showFocusSettings = false
    @State private var showBreathingSettings = false
    @State private var showHistorySettings = false

    // Onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var presentOnboarding: Bool = false

    var body: some View {
        TabView {
            // Focus tab
            NavigationStack {
                TimerView()
                    .navigationTitle("Focus")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showFocusSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Focus Settings")
                        }
                    }
            }
            .tabItem {
                Label("Focus", systemImage: "target")
            }
            .sheet(isPresented: $showFocusSettings) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            }

            // Breathing tab
            NavigationStack {
                BreathingView()
                    .navigationTitle("Breathing")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showBreathingSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Breathing Settings")
                        }
                    }
            }
            .tabItem {
                Label("Breathing", systemImage: "wind")
            }
            .sheet(isPresented: $showBreathingSettings) {
                BreathingSettingsView()
                    .presentationDetents([.medium, .large])
            }

            // History tab
            NavigationStack {
                HistoryView()
                    .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showHistorySettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("History Settings")
                        }
                    }
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .sheet(isPresented: $showHistorySettings) {
                HistorySettingsView()
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $presentOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
                presentOnboarding = false
            }
            .interactiveDismissDisabled(true)
        }
        .environmentObject(settings)
        .environmentObject(persistence)
        .environmentObject(timerVM)
        .onAppear {
            timerVM.configure(settings: settings, persistence: persistence)
            Task { await NotificationsManager.shared.requestAuthorizationIfNeeded() }
            if !hasCompletedOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    presentOnboarding = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroSettings())
        .environmentObject(Persistence())
        .environmentObject(FocusTimerViewModel())
}
