//
//   TaskPlacementFeaturesTests.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/8/26.
//

import Foundation
import Testing

@testable import Smart_Day_Planner

struct TaskPlacementFeaturesTests {

    @Test
    func featuresContainTaskAndSlotValues() {
        let userId = UUID()

        let slotStart = makeFeatureTestDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 9
        )

        let slotEnd = makeFeatureTestDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 11
        )

        let deadline = makeFeatureTestDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 17
        )

        let task = TaskItem(
            userId: userId,
            title: "Coding task",
            durationMinutes: 60,
            priority: 5,
            deadline: deadline,
            energyLevel: 4,
            category: .coding
        )

        let slot = TimeSlot(
            startDate: slotStart,
            endDate: slotEnd
        )

        let features = TaskPlacementFeatures(
            task: task,
            slot: slot
        )

        #expect(features.priority == 5)
        #expect(features.energyLevel == 4)
        #expect(features.durationMinutes == 60)
        #expect(features.slotDurationMinutes == 120)
        #expect(features.remainingSlotMinutes == 60)
        #expect(features.categoryValue == TaskCategory.coding.modelValue)

        let expectedDeadlineMinutes =
            deadline.timeIntervalSince(slotStart) / 60

        #expect(
            abs(
                features.minutesUntilDeadline -
                expectedDeadlineMinutes
            ) < 0.001
        )
    }

    @Test
    func remainingSlotMinutesCanBeNegativeForOversizedTask() {
        let userId = UUID()

        let startDate = makeFeatureTestDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 9
        )

        let endDate = makeFeatureTestDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 10
        )

        let task = TaskItem(
            userId: userId,
            title: "Long task",
            durationMinutes: 90,
            priority: 3,
            deadline: makeFeatureTestDate(
                year: 2026,
                month: 8,
                day: 8,
                hour: 18
            ),
            energyLevel: 3,
            category: .work
        )

        let features = TaskPlacementFeatures(
            task: task,
            slot: TimeSlot(
                startDate: startDate,
                endDate: endDate
            )
        )

        #expect(features.slotDurationMinutes == 60)
        #expect(features.remainingSlotMinutes == -30)
    }

    @Test
    func categoryValuesRemainStableForModelInputs() {
        #expect(TaskCategory.study.modelValue == 0)
        #expect(TaskCategory.coding.modelValue == 1)
        #expect(TaskCategory.work.modelValue == 2)
        #expect(TaskCategory.admin.modelValue == 3)
        #expect(TaskCategory.exercise.modelValue == 4)
        #expect(TaskCategory.errand.modelValue == 5)
        #expect(TaskCategory.personal.modelValue == 6)
    }
}

private func makeFeatureTestDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int = 0
) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = 0

    return Calendar.current.date(
        from: components
    )!
}
