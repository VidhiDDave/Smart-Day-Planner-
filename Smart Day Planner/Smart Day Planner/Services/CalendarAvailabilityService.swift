//
//  CalendarAvailabilityService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct CalendarAvailabilityService {
    func availableTimeSlots(
        for events: [CalendarEvent],
        dayStart: Date = .todayAt(hour: AppConfig.defaultDayStartHour),
        dayEnd: Date = .todayAt(hour: AppConfig.defaultDayEndHour)
    ) -> [TimeSlot] {
        let sortedEvents = events
            .filter { $0.endDate > dayStart && $0.startDate < dayEnd }
            .sorted { $0.startDate < $1.startDate }

        var availableSlots: [TimeSlot] = []
        var currentStart = dayStart

        for event in sortedEvents {
            let eventStart = max(event.startDate, dayStart)
            let eventEnd = min(event.endDate, dayEnd)

            if eventStart > currentStart {
                availableSlots.append(
                    TimeSlot(startDate: currentStart, endDate: eventStart)
                )
            }

            if eventEnd > currentStart {
                currentStart = eventEnd
            }
        }

        if currentStart < dayEnd {
            availableSlots.append(
                TimeSlot(startDate: currentStart, endDate: dayEnd)
            )
        }

        return availableSlots.filter { $0.durationMinutes > 0 }
    }
}
