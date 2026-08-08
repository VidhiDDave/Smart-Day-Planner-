//
//  TaskPlacementFeatures.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/7/26.
//

import Foundation

struct TaskPlacementFeatures: Codable, Equatable {
    let priority: Double
    let energyLevel: Double
    let durationMinutes: Double
    let minutesUntilDeadline: Double
    let startHour: Double
    let slotDurationMinutes: Double
    let remainingSlotMinutes: Double
    let categoryValue: Double

    init(task: TaskItem, slot: TimeSlot) {
        priority = Double(task.priority)
        energyLevel = Double(task.energyLevel)
        durationMinutes = Double(task.durationMinutes)

        minutesUntilDeadline = task.deadline.timeIntervalSince(slot.startDate) / 60

        startHour = Double(
            Calendar.current.component(.hour, from: slot.startDate)
        )

        slotDurationMinutes = Double(slot.durationMinutes)

        remainingSlotMinutes = Double(
            slot.durationMinutes - task.durationMinutes
        )

        categoryValue = task.category.modelValue
    }
}
