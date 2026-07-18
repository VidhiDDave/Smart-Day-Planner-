//
//  ContentView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var plannerViewModel = PlannerViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                mainTabView
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.restoreSession()
        }
    }

    private var mainTabView: some View {
        TabView {
            TaskListView(viewModel: plannerViewModel)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            CalendarBlocksView(viewModel: plannerViewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            OptimizedScheduleView(viewModel: plannerViewModel)
                .tabItem {
                    Label("Schedule", systemImage: "sparkles")
                }

            SettingsView(authViewModel: authViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
