//
//  Smart_Day_PlannerTests.swift
//  Smart Day PlannerTests
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation
import Testing

@testable import Smart_Day_Planner

struct Smart_Day_PlannerTests {

    @Test
    func timeSlotCalculatesDurationInMinutes() {
        let startDate = makeDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 9
        )

        let endDate = makeDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 10,
            minute: 30
        )

        let slot = TimeSlot(
            startDate: startDate,
            endDate: endDate
        )

        #expect(slot.durationMinutes == 90)
    }

    @Test
    func timeSlotCanFitTaskWhenDurationMatchesExactly() {
        let startDate = makeDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 9
        )

        let endDate = makeDate(
            year: 2026,
            month: 8,
            day: 8,
            hour: 10
        )

        let slot = TimeSlot(
            startDate: startDate,
            endDate: endDate
        )

        #expect(slot.canFit(durationMinutes: 60))
        #expect(!slot.canFit(durationMinutes: 61))
    }
}

private func makeDate(
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
