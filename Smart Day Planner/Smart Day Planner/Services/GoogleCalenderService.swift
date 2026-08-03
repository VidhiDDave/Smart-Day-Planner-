//
//  GoogleCalenderService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

//
//  GoogleCalendarService.swift
//  Smart Day Planner
//

import Foundation
import GoogleSignIn
import UIKit

enum GoogleCalendarServiceError: LocalizedError {
    case missingSignedInUser
    case missingRootViewController
    case missingAccessToken
    case invalidResponse(String)

    var errorDescription: String? {
        switch self {
        case .missingSignedInUser:
            return "Please sign in with Google before connecting Google Calendar."
        case .missingRootViewController:
            return "Unable to find a root view controller for Google Calendar access."
        case .missingAccessToken:
            return "Google Calendar access token is unavailable."
        case .invalidResponse(let message):
            return message
        }
    }
}

final class GoogleCalendarService {
    private let calendarScope = "https://www.googleapis.com/auth/calendar.readonly"

    func connectCalendar() async throws {
        try await requestCalendarAccessIfNeeded()
    }

    func disconnectCalendar() async {
        // Full Google sign-out is handled by AuthService.
    }

    func fetchTodayEvents(for userId: UUID) async throws -> [CalendarEvent] {
        try await requestCalendarAccessIfNeeded()

        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            throw GoogleCalendarServiceError.missingSignedInUser
        }

        let accessToken = try await refreshAccessToken(for: currentUser)
        let calendars = try await fetchCalendarList(accessToken: accessToken)

        var importedEvents: [CalendarEvent] = []

        for calendar in calendars {
            let events = try await fetchTodayEvents(
                calendarId: calendar.id,
                accessToken: accessToken,
                userId: userId
            )

            importedEvents.append(contentsOf: events)
        }

        return importedEvents
    }

    private func fetchCalendarList(accessToken: String) async throws -> [GoogleCalendarListItem] {
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/users/me/calendarList") else {
            throw GoogleCalendarServiceError.invalidResponse("Unable to create Google Calendar list request.")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarServiceError.invalidResponse("Unable to read Google Calendar list response.")
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let responseText = String(data: data, encoding: .utf8) ?? "No response body"
            throw GoogleCalendarServiceError.invalidResponse(
                "Google Calendar list failed with status \(httpResponse.statusCode): \(responseText)"
            )
        }

        return try JSONDecoder()
            .decode(GoogleCalendarListResponse.self, from: data)
            .items
            .filter { $0.accessRole != "freeBusyReader" }
    }

    private func fetchTodayEvents(
        calendarId: String,
        accessToken: String,
        userId: UUID
    ) async throws -> [CalendarEvent] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        let interval = DateInterval(start: startOfDay, end: endOfDay)

        let encodedCalendarId = calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId

        var components = URLComponents(
            string: "https://www.googleapis.com/calendar/v3/calendars/\(encodedCalendarId)/events"
        )

        components?.queryItems = [
            URLQueryItem(name: "timeMin", value: interval.start.iso8601Text),
            URLQueryItem(name: "timeMax", value: interval.end.iso8601Text),
            URLQueryItem(name: "timeZone", value: TimeZone.current.identifier),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime")
        ]

        guard let url = components?.url else {
            throw GoogleCalendarServiceError.invalidResponse("Unable to create Google Calendar events request.")
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarServiceError.invalidResponse("Unable to read Google Calendar events response.")
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let responseText = String(data: data, encoding: .utf8) ?? "No response body"
            throw GoogleCalendarServiceError.invalidResponse(
                "Google Calendar events failed with status \(httpResponse.statusCode): \(responseText)"
            )
        }

        let googleResponse = try JSONDecoder().decode(
            GoogleCalendarEventsResponse.self,
            from: data
        )

        return googleResponse.items.compactMap { item in
            item.calendarEvent(userId: userId)
        }
    }

    private func requestCalendarAccessIfNeeded() async throws {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            throw GoogleCalendarServiceError.missingSignedInUser
        }

        if currentUser.grantedScopes?.contains(calendarScope) == true {
            return
        }

        guard let presentingViewController = await MainActor.run(body: {
            UIApplication.shared.rootViewController
        }) else {
            throw GoogleCalendarServiceError.missingRootViewController
        }

        _ = try await currentUser.addScopes(
            [calendarScope],
            presenting: presentingViewController
        )
    }

    private func refreshAccessToken(for user: GIDGoogleUser) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            user.refreshTokensIfNeeded { refreshedUser, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let token = refreshedUser?.accessToken.tokenString else {
                    continuation.resume(throwing: GoogleCalendarServiceError.missingAccessToken)
                    return
                }

                continuation.resume(returning: token)
            }
        }
    }
}

private struct GoogleCalendarListResponse: Decodable {
    let items: [GoogleCalendarListItem]
}

private struct GoogleCalendarListItem: Decodable {
    let id: String
    let summary: String?
    let accessRole: String
}

private struct GoogleCalendarEventsResponse: Decodable {
    let items: [GoogleCalendarEventItem]
}

private struct GoogleCalendarEventItem: Decodable {
    let id: String
    let summary: String?
    let start: GoogleCalendarEventDate
    let end: GoogleCalendarEventDate

    func calendarEvent(userId: UUID) -> CalendarEvent? {
        guard let startDate = start.dateValue,
              let endDate = end.dateValue,
              endDate > startDate else {
            return nil
        }

        return CalendarEvent(
            userId: userId,
            title: summary ?? "Google Calendar Event",
            startDate: startDate,
            endDate: endDate,
            source: "google",
            externalEventId: id
        )
    }
}

private struct GoogleCalendarEventDate: Decodable {
    let dateTime: String?
    let date: String?

    var dateValue: Date? {
        if let dateTime {
            return Date.googleCalendarDate(from: dateTime)
        }

        if let date {
            return Date.googleCalendarDate(from: "\(date)T00:00:00Z")
        }

        return nil
    }
}

private extension Date {
    var iso8601Text: String {
        ISO8601DateFormatter.googleCalendar.string(from: self)
    }

    static func googleCalendarDate(from string: String) -> Date? {
        ISO8601DateFormatter.googleCalendar.date(from: string)
            ?? ISO8601DateFormatter.googleCalendarNoFractionalSeconds.date(from: string)
    }
}

private extension ISO8601DateFormatter {
    static let googleCalendar: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    static let googleCalendarNoFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime
        ]
        return formatter
    }()
}
