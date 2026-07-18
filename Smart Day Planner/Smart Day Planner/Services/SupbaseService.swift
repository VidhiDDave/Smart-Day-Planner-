//
//  SupbaseService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation

final class SupabaseService {
    func fetchProfile(for userId: UUID) async throws -> UserProfile? {
        // Real Supabase profile fetch will be added later.
        nil
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        // Real Supabase profile insert/update will be added later.
    }

    func fetchTasks(for userId: UUID) async throws -> [TaskItem] {
        // Real Supabase task fetch will be added later.
        []
    }

    func saveTask(_ task: TaskItem) async throws {
        // Real Supabase task insert/update will be added later.
    }

    func deleteTask(_ task: TaskItem) async throws {
        // Real Supabase task delete will be added later.
    }

    func fetchCalendarEvents(for userId: UUID) async throws -> [CalendarEvent] {
        // Real Supabase calendar event fetch will be added later.
        []
    }

    func saveCalendarEvent(_ event: CalendarEvent) async throws {
        // Real Supabase calendar event insert/update will be added later.
    }

    func deleteCalendarEvent(_ event: CalendarEvent) async throws {
        // Real Supabase calendar event delete will be added later.
    }

    func saveScheduledTasks(_ scheduledTasks: [ScheduledTask]) async throws {
        // Real Supabase scheduled task save will be added later.
    }
}
