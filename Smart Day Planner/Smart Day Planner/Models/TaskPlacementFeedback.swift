//
//  TaskPlacementFeedback.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/8/26.
//

import Foundation

enum TaskPlacementFeedbackType: String, Codable {
    case accepted
    case completed
    case moved
    case skipped
}

struct TaskPlacementFeedback: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let taskId: UUID?

    let priority: Double
    let energyLevel: Double
    let durationMinutes: Double
    let minutesUntilDeadline: Double
    let startHour: Double
    let slotDurationMinutes: Double
    let remainingSlotMinutes: Double
    let categoryValue: Double

    let suggestedStartDate: Date?
    let actualStartDate: Date?

    let feedbackType: TaskPlacementFeedbackType
    let targetScore: Double
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        taskId: UUID,
        features: TaskPlacementFeatures,
        suggestedStartDate: Date?,
        actualStartDate: Date? = nil,
        feedbackType: TaskPlacementFeedbackType,
        targetScore: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.taskId = taskId

        self.priority = features.priority
        self.energyLevel = features.energyLevel
        self.durationMinutes = features.durationMinutes
        self.minutesUntilDeadline = features.minutesUntilDeadline
        self.startHour = features.startHour
        self.slotDurationMinutes = features.slotDurationMinutes
        self.remainingSlotMinutes = features.remainingSlotMinutes
        self.categoryValue = features.categoryValue

        self.suggestedStartDate = suggestedStartDate
        self.actualStartDate = actualStartDate

        self.feedbackType = feedbackType
        self.targetScore = min(max(targetScore, 0.0), 1.0)
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case taskId = "task_id"

        case priority
        case energyLevel = "energy_level"
        case durationMinutes = "duration_minutes"
        case minutesUntilDeadline = "minutes_until_deadline"
        case startHour = "start_hour"
        case slotDurationMinutes = "slot_duration_minutes"
        case remainingSlotMinutes = "remaining_slot_minutes"
        case categoryValue = "category_value"

        case suggestedStartDate = "suggested_start_date"
        case actualStartDate = "actual_start_date"

        case feedbackType = "feedback_type"
        case targetScore = "target_score"
        case createdAt = "created_at"
    }
}
