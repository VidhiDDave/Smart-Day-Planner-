//
//  MLScoringService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/7/26.
//

import Foundation
import CoreML

struct MLScoringService {
    private let model: TaskPlacementScorer?

    init() {
        let configuration = MLModelConfiguration()
        self.model = try? TaskPlacementScorer(configuration: configuration)
    }

    func score(task: TaskItem, in slot: TimeSlot) -> Double {
        guard slot.canFit(durationMinutes: task.durationMinutes) else {
            return 0.0
        }

        let features = TaskPlacementFeatures(task: task, slot: slot)

        if let predictedScore = prediction(for: features) {
            return predictedScore
        }

        return heuristicScore(task: task, slot: slot)
    }

    private func prediction(for features: TaskPlacementFeatures) -> Double? {
        guard let model else {
            return nil
        }

        do {
            let output = try model.prediction(
                priority: features.priority,
                energyLevel: features.energyLevel,
                durationMinutes: features.durationMinutes,
                minutesUntilDeadline: features.minutesUntilDeadline,
                startHour: features.startHour,
                slotDurationMinutes: features.slotDurationMinutes,
                remainingSlotMinutes: features.remainingSlotMinutes,
                categoryValue: features.categoryValue
            )

            return min(max(output.score, 0.0), 1.0)
        } catch {
            return nil
        }
    }

    private func heuristicScore(task: TaskItem, slot: TimeSlot) -> Double {
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
        switch priority {
        case 5:
            return 0.20
        case 4:
            return 0.15
        case 3:
            return 0.10
        case 2:
            return 0.05
        default:
            return 0.0
        }
    }

    private func deadlineScore(_ hoursRemaining: Double) -> Double {
        if hoursRemaining <= 0 {
            return -0.25
        } else if hoursRemaining <= 6 {
            return 0.20
        } else if hoursRemaining <= 24 {
            return 0.15
        } else if hoursRemaining <= 72 {
            return 0.10
        } else {
            return 0.05
        }
    }

    private func durationFitScore(remainingMinutes: Double) -> Double {
        if remainingMinutes < 0 {
            return -1.0
        } else if remainingMinutes <= 30 {
            return 0.15
        } else if remainingMinutes <= 90 {
            return 0.10
        } else {
            return 0.05
        }
    }

    private func energyTimeScore(
        energyLevel: Int,
        hour: Int
    ) -> Double {
        if energyLevel >= 4 {
            if (8..<12).contains(hour) {
                return 0.15
            } else if (12..<17).contains(hour) {
                return 0.10
            } else {
                return 0.0
            }
        }

        if energyLevel <= 2 {
            if hour >= 17 {
                return 0.10
            } else {
                return 0.05
            }
        }

        return 0.075
    }

    private func categoryTimeScore(
        category: TaskCategory,
        hour: Int
    ) -> Double {
        switch category {
        case .study:
            return (8..<14).contains(hour) ? 0.10 : 0.05

        case .coding:
            return (8..<15).contains(hour) ? 0.10 : 0.05

        case .work:
            return (9..<17).contains(hour) ? 0.10 : 0.03

        case .admin:
            return (9..<17).contains(hour) ? 0.08 : 0.03

        case .exercise:
            return hour < 10 || hour >= 16 ? 0.10 : 0.05

        case .errand:
            return (9..<18).contains(hour) ? 0.08 : 0.03

        case .personal:
            return 0.06
        }
    }
}
