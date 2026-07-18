//
//  GoogleCalenderService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation

final class GoogleCalendarService {
    private(set) var isConnected = false

    func connectCalendar() async throws {
        // Real Google Calendar OAuth permission flow will be added later.
        isConnected = true
    }

    func disconnectCalendar() async {
        // Real token cleanup will be added later.
        isConnected = false
    }

    func fetchTodayEvents(for userId: UUID) async throws -> [CalendarEvent] {
        // Real Google Calendar event fetch will be added later.
        []
    }
}
