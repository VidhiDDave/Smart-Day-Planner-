//
//  DateFormatter+Planner.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

extension DateFormatter {
    static let plannerTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static let plannerDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Date {
    var plannerTimeText: String {
        DateFormatter.plannerTime.string(from: self)
    }

    var plannerDateText: String {
        DateFormatter.plannerDate.string(from: self)
    }

    static func todayAt(hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let now = Date()

        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: now
        ) ?? now
    }
}

extension ClosedRange where Bound == Date {
    var plannerTimeRangeText: String {
        "\(lowerBound.plannerTimeText) - \(upperBound.plannerTimeText)"
    }
}
