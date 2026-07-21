//
//  SupbaseService.swift
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

    func fetchProfile(for userId: UUID) async throws -> UserProfile? {
        try validateConfiguration()

        // Real profile fetch will be added in a later auth/profile PR.
        return nil
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        try validateConfiguration()

        // Real Supabase profile insert/update will be added in a later auth/profile PR.
    }

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

    func fetchCalendarEvents(for userId: UUID) async throws -> [CalendarEvent] {
        try validateConfiguration()

        // Real calendar event fetch will be added in a later PR.
        return []
    }

    func saveCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        // Real calendar event insert/update will be added in a later PR.
    }

    func deleteCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        // Real calendar event delete will be added in a later PR.
    }

    func saveScheduledTasks(_ scheduledTasks: [ScheduledTask]) async throws {
        try validateConfiguration()

        // Real scheduled task persistence will be added in a later PR.
    }
}
