//
//  TimeSlot.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let startDate: Date
    let endDate: Date

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    func canFit(durationMinutes: Int) -> Bool {
        self.durationMinutes >= durationMinutes
    }
}
