//
//  SettingsView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let profile = authViewModel.userProfile {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.fullName ?? "Signed In User")
                                .font(.headline)

                            Text(profile.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                Section("Calendar") {
                    if settingsViewModel.isGoogleCalendarConnected {
                        Label("Google Calendar connected", systemImage: "checkmark.circle.fill")

                        Button("Disconnect Google Calendar") {
                            Task {
                                await settingsViewModel.disconnectGoogleCalendar()
                            }
                        }
                    } else {
                        Button {
                            Task {
                                await settingsViewModel.connectGoogleCalendar()
                            }
                        } label: {
                            Label("Connect Google Calendar", systemImage: "calendar.badge.plus")
                        }
                    }

                    if let errorMessage = settingsViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Backend") {
                    Label("Supabase sync scaffold added", systemImage: "externaldrive.connected.to.line.below")
                    Text("Task and calendar data are still local for now. Supabase persistence will be connected in a later PR.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
    SettingsView(authViewModel: AuthViewModel())
}
