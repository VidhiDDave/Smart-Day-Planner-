//
//  MLScoringService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//
// temp

import Foundation

/// Rule-based scoring service used as the first scheduling intelligence layer.
/// This can later be replaced with a Core ML model using the same task-slot inputs.
struct MLScoringService {
    func score(task: TaskItem, in slot: TimeSlot) -> Double {
        guard slot.canFit(durationMinutes: task.durationMinutes) else {
            return 0.0
        }

        let features = TaskPlacementFeatures(task: task, slot: slot)

        var score = 0.5

        score += priorityScore(Int(features.priority))
        score += deadlineScore(features.minutesUntilDeadline / 60)
        score += durationFitScore(
            remainingMinutes: features.remainingSlotMinutes
        )
        score += energyTimeScore(
            energyLevel: Int(features.energyLevel),
            hour: Int(features.startHour)
        )
        score += categoryTimeScore(
            category: task.category,
            hour: Int(features.startHour)
        )

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

    private func durationFitScore(remainingMinutes: Double) -> Double {
        if remainingMinutes < 0 {
            return -1.0
        } else if remainingMinutes <= 30 {
            return 0.15
        } else if remainingMinutes <= 90 {
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
