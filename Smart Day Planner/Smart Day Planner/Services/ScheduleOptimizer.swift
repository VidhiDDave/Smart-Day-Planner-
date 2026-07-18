//
//  ScheduleOptimizer.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct ScheduleOptimizer {
    private let scoringService = MLScoringService()

    func generateSchedule(
        tasks: [TaskItem],
        calendarEvents: [CalendarEvent],
        availableSlots: [TimeSlot]
    ) -> [ScheduledTask] {
        var remainingSlots = availableSlots.sorted { $0.startDate < $1.startDate }
        var scheduledTasks: [ScheduledTask] = []

        let sortedTasks = tasks
            .filter { !$0.isCompleted }
            .sorted {
                if $0.priority == $1.priority {
                    return $0.deadline < $1.deadline
                }

                return $0.priority > $1.priority
            }

        for task in sortedTasks {
            guard let bestPlacement = bestPlacement(for: task, in: remainingSlots) else {
                continue
            }

            let scheduledTask = ScheduledTask(
                userId: task.userId,
                taskId: task.id,
                task: task,
                startDate: bestPlacement.startDate,
                endDate: bestPlacement.endDate,
                score: bestPlacement.score,
                explanation: explanation(for: task, score: bestPlacement.score)
            )

            scheduledTasks.append(scheduledTask)

            remainingSlots = updateRemainingSlots(
                afterScheduling: scheduledTask,
                in: remainingSlots
            )
        }

        return scheduledTasks.sorted { $0.startDate < $1.startDate }
    }

    private func bestPlacement(
        for task: TaskItem,
        in slots: [TimeSlot]
    ) -> (startDate: Date, endDate: Date, score: Double)? {
        var best: (startDate: Date, endDate: Date, score: Double)?

        for slot in slots where slot.canFit(durationMinutes: task.durationMinutes) {
            let startDate = slot.startDate
            guard let endDate = Calendar.current.date(
                byAdding: .minute,
                value: task.durationMinutes,
                to: startDate
            ) else {
                continue
            }

            guard endDate <= slot.endDate else {
                continue
            }

            guard endDate <= task.deadline else {
                continue
            }

            let candidateSlot = TimeSlot(startDate: startDate, endDate: endDate)
            let score = scoringService.score(task: task, in: candidateSlot)

            if best == nil || score > best!.score {
                best = (startDate, endDate, score)
            }
        }

        return best
    }

    private func updateRemainingSlots(
        afterScheduling scheduledTask: ScheduledTask,
        in slots: [TimeSlot]
    ) -> [TimeSlot] {
        var updatedSlots: [TimeSlot] = []

        for slot in slots {
            if scheduledTask.endDate <= slot.startDate || scheduledTask.startDate >= slot.endDate {
                updatedSlots.append(slot)
                continue
            }

            if scheduledTask.startDate > slot.startDate {
                updatedSlots.append(
                    TimeSlot(startDate: slot.startDate, endDate: scheduledTask.startDate)
                )
            }

            if scheduledTask.endDate < slot.endDate {
                updatedSlots.append(
                    TimeSlot(startDate: scheduledTask.endDate, endDate: slot.endDate)
                )
            }
        }

        return updatedSlots.filter { $0.durationMinutes > 0 }
    }

    private func explanation(for task: TaskItem, score: Double) -> String {
        let roundedScore = Int(score * 100)

        if task.priority >= 4 {
            return "High-priority task placed in a strong available time block. Match score: \(roundedScore)%."
        }

        switch task.category {
        case .study, .coding, .work:
            return "Scheduled in a focus-friendly block before the deadline. Match score: \(roundedScore)%."
        case .admin, .errand:
            return "Placed into an efficient available gap. Match score: \(roundedScore)%."
        case .exercise:
            return "Scheduled during a time that generally works well for exercise. Match score: \(roundedScore)%."
        case .personal:
            return "Placed into an open block that fits the task duration. Match score: \(roundedScore)%."
        }
    }
}
