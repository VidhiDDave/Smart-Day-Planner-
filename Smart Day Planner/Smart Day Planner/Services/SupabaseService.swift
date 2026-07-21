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

    var errorDescription: String? {
        switch self {
        case .invalidProjectURL:
            return "The Supabase project URL is invalid."
        case .missingConfiguration:
            return "Supabase configuration is missing."
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

    func validateConfiguration() throws {
        guard AppConfig.isSupabaseConfigured else {
            throw SupabaseServiceError.missingConfiguration
        }

        guard URL(string: AppConfig.supabaseURL) != nil else {
            throw SupabaseServiceError.invalidProjectURL
        }
    }

    func fetchProfile(for userId: UUID) async throws -> UserProfile? {
        try validateConfiguration()

        // Real profile fetch will be added in the next Supabase data PR.
        return nil
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        try validateConfiguration()

        // Real Supabase profile insert/update will be added later.
    }

    func fetchTasks(for userId: UUID) async throws -> [TaskItem] {
        try validateConfiguration()

        // Real Supabase task fetch will be added later.
        return []
    }

    func saveTask(_ task: TaskItem) async throws {
        try validateConfiguration()

        // Real Supabase task insert/update will be added later.
    }

    func deleteTask(_ task: TaskItem) async throws {
        try validateConfiguration()

        // Real Supabase task delete will be added later.
    }

    func fetchCalendarEvents(for userId: UUID) async throws -> [CalendarEvent] {
        try validateConfiguration()

        // Real Supabase calendar event fetch will be added later.
        return []
    }

    func saveCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        // Real Supabase calendar event insert/update will be added later.
    }

    func deleteCalendarEvent(_ event: CalendarEvent) async throws {
        try validateConfiguration()

        // Real Supabase calendar event delete will be added later.
    }

    func saveScheduledTasks(_ scheduledTasks: [ScheduledTask]) async throws {
        try validateConfiguration()

        // Real Supabase scheduled task save will be added later.
    }
}
