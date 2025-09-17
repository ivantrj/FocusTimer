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

    @State private var showSettings = false

    var body: some View {
        TabView {
            NavigationStack {
                TimerView()
                    .navigationTitle("Focus")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Settings")
                        }
                    }
            }
            .tabItem {
                Label("Focus", systemImage: "target")
            }

            NavigationStack {
                BreathingView()
                    .navigationTitle("Breathing")
            }
            .tabItem {
                Label("Breathing", systemImage: "wind")
            }

            NavigationStack {
                HistoryView()
                    .navigationTitle("History")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Settings")
                        }
                    }
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
        }
        .environmentObject(settings)
        .environmentObject(persistence)
        .environmentObject(timerVM)
        .onAppear {
            timerVM.configure(settings: settings, persistence: persistence)
            Task { await NotificationsManager.shared.requestAuthorizationIfNeeded() }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroSettings())
        .environmentObject(Persistence())
        .environmentObject(FocusTimerViewModel())
}
