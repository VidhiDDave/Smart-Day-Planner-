//
//  ScheduleOptimizerTests.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/8/26.
//

import Foundation
import Testing

@testable import Smart_Day_Planner

struct ScheduleOptimizerTests {

    @Test
    func completedTasksAreExcludedFromGeneratedSchedule() {
        let userId = UUID()

        let dayStart = optimizerDate(
            hour: 9
        )

        let dayEnd = optimizerDate(
            hour: 12
        )

        let completedTask = TaskItem(
            userId: userId,
            title: "Completed task",
            durationMinutes: 60,
            priority: 5,
            deadline: optimizerDate(hour: 18),
            energyLevel: 4,
            category: .coding,
            isCompleted: true
        )

        let activeTask = TaskItem(
            userId: userId,
            title: "Active task",
            durationMinutes: 60,
            priority: 3,
            deadline: optimizerDate(hour: 18),
            energyLevel: 3,
            category: .study
        )

        let optimizer = ScheduleOptimizer()

        let schedule = optimizer.generateSchedule(
            tasks: [
                completedTask,
                activeTask
            ],
            calendarEvents: [],
            availableSlots: [
                TimeSlot(
                    startDate: dayStart,
                    endDate: dayEnd
                )
            ]
        )

        #expect(schedule.count == 1)
        #expect(schedule.first?.taskId == activeTask.id)
        #expect(
            !schedule.contains {
                $0.taskId == completedTask.id
            }
        )
    }

    @Test
    func taskIsNotScheduledPastDeadline() {
        let userId = UUID()

        let task = TaskItem(
            userId: userId,
            title: "Deadline task",
            durationMinutes: 60,
            priority: 5,
            deadline: optimizerDate(
                hour: 9,
                minute: 30
            ),
            energyLevel: 4,
            category: .work
        )

        let schedule = ScheduleOptimizer().generateSchedule(
            tasks: [task],
            calendarEvents: [],
            availableSlots: [
                TimeSlot(
                    startDate: optimizerDate(hour: 9),
                    endDate: optimizerDate(hour: 11)
                )
            ]
        )

        #expect(schedule.isEmpty)
    }

    @Test
    func taskThatDoesNotFitAvailableSlotIsSkipped() {
        let userId = UUID()

        let task = TaskItem(
            userId: userId,
            title: "Too long",
            durationMinutes: 120,
            priority: 5,
            deadline: optimizerDate(hour: 20),
            energyLevel: 5,
            category: .coding
        )

        let schedule = ScheduleOptimizer().generateSchedule(
            tasks: [task],
            calendarEvents: [],
            availableSlots: [
                TimeSlot(
                    startDate: optimizerDate(hour: 9),
                    endDate: optimizerDate(hour: 10)
                )
            ]
        )

        #expect(schedule.isEmpty)
    }

    @Test
    func generatedTasksDoNotOverlap() {
        let userId = UUID()

        let firstTask = TaskItem(
            userId: userId,
            title: "First",
            durationMinutes: 60,
            priority: 5,
            deadline: optimizerDate(hour: 18),
            energyLevel: 5,
            category: .coding
        )

        let secondTask = TaskItem(
            userId: userId,
            title: "Second",
            durationMinutes: 60,
            priority: 4,
            deadline: optimizerDate(hour: 18),
            energyLevel: 4,
            category: .study
        )

        let thirdTask = TaskItem(
            userId: userId,
            title: "Third",
            durationMinutes: 60,
            priority: 3,
            deadline: optimizerDate(hour: 18),
            energyLevel: 3,
            category: .work
        )

        let schedule = ScheduleOptimizer().generateSchedule(
            tasks: [
                firstTask,
                secondTask,
                thirdTask
            ],
            calendarEvents: [],
            availableSlots: [
                TimeSlot(
                    startDate: optimizerDate(hour: 9),
                    endDate: optimizerDate(hour: 12)
                )
            ]
        )

        #expect(schedule.count == 3)

        let sortedSchedule = schedule.sorted {
            $0.startDate < $1.startDate
        }

        for index in 0..<(sortedSchedule.count - 1) {
            let current = sortedSchedule[index]
            let next = sortedSchedule[index + 1]

            #expect(
                current.endDate <= next.startDate
            )
        }
    }

    @Test
    func generatedScheduleIsReturnedInChronologicalOrder() {
        let userId = UUID()

        let firstTask = TaskItem(
            userId: userId,
            title: "High priority",
            durationMinutes: 30,
            priority: 5,
            deadline: optimizerDate(hour: 20),
            energyLevel: 4,
            category: .coding
        )

        let secondTask = TaskItem(
            userId: userId,
            title: "Lower priority",
            durationMinutes: 30,
            priority: 2,
            deadline: optimizerDate(hour: 20),
            energyLevel: 2,
            category: .admin
        )

        let schedule = ScheduleOptimizer().generateSchedule(
            tasks: [
                secondTask,
                firstTask
            ],
            calendarEvents: [],
            availableSlots: [
                TimeSlot(
                    startDate: optimizerDate(hour: 13),
                    endDate: optimizerDate(hour: 14)
                ),
                TimeSlot(
                    startDate: optimizerDate(hour: 9),
                    endDate: optimizerDate(hour: 10)
                )
            ]
        )

        for index in 0..<(max(schedule.count - 1, 0)) {
            #expect(
                schedule[index].startDate <=
                schedule[index + 1].startDate
            )
        }
    }
}

private func optimizerDate(
    hour: Int,
    minute: Int = 0
) -> Date {
    var components = DateComponents()
    components.year = 2026
    components.month = 8
    components.day = 8
    components.hour = hour
    components.minute = minute
    components.second = 0

    return Calendar.current.date(
        from: components
    )!
}
