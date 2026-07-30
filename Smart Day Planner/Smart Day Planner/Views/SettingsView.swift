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
                accountSection
                configurationSection
                calendarSection
                backendSection
                aboutSection
            }
            .navigationTitle("Settings")
            .onAppear {
                settingsViewModel.refreshConfigurationStatus()
            }
        }
    }

    private var accountSection: some View {
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
    }

    private var configurationSection: some View {
        Section("Configuration") {
            statusRow(
                title: "Supabase",
                status: settingsViewModel.configurationStatus.supabaseStatusText,
                isConfigured: settingsViewModel.configurationStatus.isSupabaseConfigured
            )

            statusRow(
                title: "Google Sign-In",
                status: settingsViewModel.configurationStatus.googleSignInStatusText,
                isConfigured: settingsViewModel.configurationStatus.isGoogleSignInConfigured
            )

            if settingsViewModel.configurationStatus.isReadyForRealAuth {
                Label("Ready for real authentication", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                Text("Real auth is not enabled yet. Add Supabase and Google OAuth values before connecting real sign-in.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var calendarSection: some View {
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
    }

    private var backendSection: some View {
        Section("Backend") {
            Label("Supabase sync scaffold added", systemImage: "externaldrive.connected.to.line.below")

            Text("Task and calendar data are still local unless Supabase is configured and real authentication is connected.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            Text("Smart Day Planner uses task priority, deadlines, duration, calendar availability, and ML-style scoring to suggest an optimized daily schedule.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func statusRow(
        title: String,
        status: String,
        isConfigured: Bool
    ) -> some View {
        HStack {
            Label(
                title,
                systemImage: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
            )
            .foregroundStyle(isConfigured ? .green : .orange)

            Spacer()

            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SettingsView(authViewModel: AuthViewModel())
}
