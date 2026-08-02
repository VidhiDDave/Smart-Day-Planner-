//
//  SupabaseService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation
import Supabase

enum SupabaseServiceError: LocalizedError {
    case invalidProjectURL
    case missingConfiguration
    case missingClient

    var errorDescription: String? {
        switch self {
        case .invalidProjectURL:
            return "The Supabase project URL is invalid."
        case .missingConfiguration:
            return "Supabase configuration is missing."
        case .missingClient:
            return "Supabase client is not available."
        }
    }
}

final class SupabaseService {
    private let client: SupabaseClient?

    init() {
        if AppConfig.isSupabaseConfigured,
           let url = URL(string: AppConfig.supabaseURL) {
            self.client = SupabaseClient(
                supabaseURL: url,
                supabaseKey: AppConfig.supabaseAnonKey
            )
        } else {
            self.client = nil
        }
    }

    var isConfigured: Bool {
        client != nil
    }

    func validateConfiguration() throws {
        guard AppConfig.isSupabaseConfigured else {
            throw SupabaseServiceError.missingConfiguration
        }

        guard URL(string: AppConfig.supabaseURL) != nil else {
            throw SupabaseServiceError.invalidProjectURL
        }

        guard client != nil else {
            throw SupabaseServiceError.missingClient
        }
    }

    // MARK: - Auth

    func signInWithGoogleIDToken(_ idToken: String) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        _ = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .google,
                idToken: idToken
            )
        )
    }

    func currentAuthenticatedUserId() async throws -> UUID? {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        let session = try await client.auth.session
        return session.user.id
    }

    func signOutFromSupabase() async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client.auth.signOut()
    }

    // MARK: - Profiles

    func fetchProfile(for userId: UUID) async throws -> UserProfile? {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        let profiles: [UserProfile] = try await client
            .from(DatabaseTable.profiles)
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return profiles.first
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client
            .from(DatabaseTable.profiles)
            .upsert(profile)
            .execute()
    }

    // MARK: - Tasks

    func fetchTasks(for userId: UUID) async throws -> [TaskItem] {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        return try await client
            .from(DatabaseTable.tasks)
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func saveTask(_ task: TaskItem) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client
            .from(DatabaseTable.tasks)
            .upsert(task)
            .execute()
    }

    func deleteTask(_ task: TaskItem) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client
            .from(DatabaseTable.tasks)
            .delete()
            .eq("id", value: task.id.uuidString)
            .execute()
    }

    // MARK: - Calendar Events

    func fetchCalendarEvents(for userId: UUID) async throws -> [CalendarEvent] {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        return try await client
            .from(DatabaseTable.calendarEvents)
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("start_date", ascending: true)
            .execute()
            .value
    }

    func saveCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client
            .from(DatabaseTable.calendarEvents)
            .upsert(event)
            .execute()
    }

    func deleteCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        guard let client else {
            throw SupabaseServiceError.missingClient
        }

        try await client
            .from(DatabaseTable.calendarEvents)
            .delete()
            .eq("id", value: event.id.uuidString)
            .execute()
    }

    // MARK: - Scheduled Tasks

    func saveScheduledTasks(_ scheduledTasks: [ScheduledTask]) async throws {
        try validateConfiguration()

        // Real scheduled task persistence will be added in a later PR.
    }
}
