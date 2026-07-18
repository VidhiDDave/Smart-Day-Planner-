//
//  ScheduledTask.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct ScheduledTask: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let taskId: UUID
    var task: TaskItem?
    var startDate: Date
    var endDate: Date
    var score: Double
    var explanation: String
    var createdAt: Date?

    init(
        id: UUID = UUID(),
        userId: UUID,
        taskId: UUID,
        task: TaskItem? = nil,
        startDate: Date,
        endDate: Date,
        score: Double,
        explanation: String,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.taskId = taskId
        self.task = task
        self.startDate = startDate
        self.endDate = endDate
        self.score = score
        self.explanation = explanation
        self.createdAt = createdAt
    }

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case taskId = "task_id"
        case task
        case startDate = "start_date"
        case endDate = "end_date"
        case score
        case explanation
        case createdAt = "created_at"
    }
}
