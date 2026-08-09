//
//  CalendarAvailabilityServiceTests.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/8/26.
//

import Foundation
import Testing

@testable import Smart_Day_Planner

struct CalendarAvailabilityServiceTests {

    @Test
    func noEventsReturnsEntireDayAsAvailable() {
        let dayStart = availabilityDate(hour: 8)
        let dayEnd = availabilityDate(hour: 18)

        let slots = CalendarAvailabilityService()
            .availableTimeSlots(
                for: [],
                dayStart: dayStart,
                dayEnd: dayEnd
            )

        #expect(slots.count == 1)
        #expect(slots[0].startDate == dayStart)
        #expect(slots[0].endDate == dayEnd)
    }

    @Test
    func calendarEventSplitsAvailableDay() {
        let userId = UUID()

        let dayStart = availabilityDate(hour: 8)
        let dayEnd = availabilityDate(hour: 18)

        let meeting = CalendarEvent(
            userId: userId,
            title: "Meeting",
            startDate: availabilityDate(hour: 10),
            endDate: availabilityDate(hour: 11)
        )

        let slots = CalendarAvailabilityService()
            .availableTimeSlots(
                for: [meeting],
                dayStart: dayStart,
                dayEnd: dayEnd
            )

        #expect(slots.count == 2)

        #expect(
            slots[0].startDate ==
            availabilityDate(hour: 8)
        )

        #expect(
            slots[0].endDate ==
            availabilityDate(hour: 10)
        )

        #expect(
            slots[1].startDate ==
            availabilityDate(hour: 11)
        )

        #expect(
            slots[1].endDate ==
            availabilityDate(hour: 18)
        )
    }

    @Test
    func overlappingCalendarEventsDoNotCreateInvalidSlots() {
        let userId = UUID()

        let firstEvent = CalendarEvent(
            userId: userId,
            title: "First meeting",
            startDate: availabilityDate(hour: 9),
            endDate: availabilityDate(hour: 11)
        )

        let overlappingEvent = CalendarEvent(
            userId: userId,
            title: "Overlapping meeting",
            startDate: availabilityDate(hour: 10),
            endDate: availabilityDate(hour: 12)
        )

        let slots = CalendarAvailabilityService()
            .availableTimeSlots(
                for: [
                    firstEvent,
                    overlappingEvent
                ],
                dayStart: availabilityDate(hour: 8),
                dayEnd: availabilityDate(hour: 18)
            )

        #expect(slots.count == 2)

        #expect(
            slots[0].startDate ==
            availabilityDate(hour: 8)
        )

        #expect(
            slots[0].endDate ==
            availabilityDate(hour: 9)
        )

        #expect(
            slots[1].startDate ==
            availabilityDate(hour: 12)
        )

        #expect(
            slots[1].endDate ==
            availabilityDate(hour: 18)
        )
    }

    @Test
    func eventsOutsideRequestedDayAreIgnored() {
        let userId = UUID()

        let beforeDay = CalendarEvent(
            userId: userId,
            title: "Earlier event",
            startDate: availabilityDate(
                day: 7,
                hour: 12
            ),
            endDate: availabilityDate(
                day: 7,
                hour: 13
            )
        )

        let slots = CalendarAvailabilityService()
            .availableTimeSlots(
                for: [beforeDay],
                dayStart: availabilityDate(hour: 8),
                dayEnd: availabilityDate(hour: 18)
            )

        #expect(slots.count == 1)

        #expect(
            slots[0].startDate ==
            availabilityDate(hour: 8)
        )

        #expect(
            slots[0].endDate ==
            availabilityDate(hour: 18)
        )
    }
}

private func availabilityDate(
    day: Int = 8,
    hour: Int,
    minute: Int = 0
) -> Date {
    var components = DateComponents()
    components.year = 2026
    components.month = 8
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = 0

    return Calendar.current.date(
        from: components
    )!
}
