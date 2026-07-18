//
//  TaskItem.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    var title: String
    var durationMinutes: Int
    var priority: Int
    var deadline: Date
    var energyLevel: Int
    var category: TaskCategory
    var isCompleted: Bool
    var createdAt: Date?

    init(
        id: UUID = UUID(),
        userId: UUID,
        title: String,
        durationMinutes: Int,
        priority: Int,
        deadline: Date,
        energyLevel: Int,
        category: TaskCategory,
        isCompleted: Bool = false,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.durationMinutes = durationMinutes
        self.priority = priority
        self.deadline = deadline
        self.energyLevel = energyLevel
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case durationMinutes = "duration_minutes"
        case priority
        case deadline
        case energyLevel = "energy_level"
        case category
        case isCompleted = "is_completed"
        case createdAt = "created_at"
    }
}
