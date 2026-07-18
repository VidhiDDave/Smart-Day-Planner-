//
//  MLScoringService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//
// temp

import Foundation

struct MLScoringService {
    func score(task: TaskItem, in slot: TimeSlot) -> Double {
        guard slot.canFit(durationMinutes: task.durationMinutes) else {
            return 0.0
        }

        let hour = Calendar.current.component(.hour, from: slot.startDate)
        let deadlineHoursRemaining = task.deadline.timeIntervalSince(slot.startDate) / 3600

        var score = 0.5

        score += priorityScore(task.priority)
        score += deadlineScore(deadlineHoursRemaining)
        score += durationFitScore(task: task, slot: slot)
        score += energyTimeScore(energyLevel: task.energyLevel, hour: hour)
        score += categoryTimeScore(category: task.category, hour: hour)

        return min(max(score, 0.0), 1.0)
    }

    private func priorityScore(_ priority: Int) -> Double {
        Double(priority) * 0.04
    }

    private func deadlineScore(_ hoursRemaining: Double) -> Double {
        if hoursRemaining < 0 {
            return -0.5
        } else if hoursRemaining <= 4 {
            return 0.2
        } else if hoursRemaining <= 8 {
            return 0.1
        } else {
            return 0.0
        }
    }

    private func durationFitScore(task: TaskItem, slot: TimeSlot) -> Double {
        let leftoverMinutes = slot.durationMinutes - task.durationMinutes

        if leftoverMinutes < 0 {
            return -1.0
        } else if leftoverMinutes <= 30 {
            return 0.15
        } else if leftoverMinutes <= 90 {
            return 0.1
        } else {
            return 0.05
        }
    }

    private func energyTimeScore(energyLevel: Int, hour: Int) -> Double {
        if energyLevel >= 4 {
            return (8...12).contains(hour) ? 0.15 : -0.05
        } else {
            return (13...18).contains(hour) ? 0.1 : 0.0
        }
    }

    private func categoryTimeScore(category: TaskCategory, hour: Int) -> Double {
        switch category {
        case .study, .coding, .work:
            return (8...12).contains(hour) ? 0.1 : 0.0
        case .admin, .errand:
            return (13...17).contains(hour) ? 0.1 : 0.0
        case .exercise:
            return (16...20).contains(hour) ? 0.15 : 0.0
        case .personal:
            return 0.03
        }
    }
}
