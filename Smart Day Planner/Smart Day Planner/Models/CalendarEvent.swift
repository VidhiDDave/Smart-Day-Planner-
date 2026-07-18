//
//  CalendarEvent.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var source: String
    var externalEventId: String?
    var createdAt: Date?

    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        source: String = "manual",
        externalEventId: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.source = source
        self.externalEventId = externalEventId
        self.createdAt = createdAt
    }

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case startDate = "start_date"
        case endDate = "end_date"
        case source
        case externalEventId = "external_event_id"
        case createdAt = "created_at"
    }
}
