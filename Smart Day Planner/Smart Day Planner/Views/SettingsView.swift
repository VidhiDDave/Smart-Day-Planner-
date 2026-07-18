//
//  SettingsView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Label("Google Sign-In coming next", systemImage: "person.crop.circle")
                    Label("Supabase sync coming next", systemImage: "externaldrive.connected.to.line.below")
                }

                Section("Calendar") {
                    Label("Optional Google Calendar connection", systemImage: "calendar.badge.plus")
                }

                Section("About") {
                    Text("Smart Day Planner uses task priority, deadlines, duration, calendar availability, and ML-style scoring to suggest an optimized daily schedule.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
