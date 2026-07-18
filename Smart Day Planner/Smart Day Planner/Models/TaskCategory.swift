//
//  TaskCategory.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case study = "Study"
    case coding = "Coding"
    case work = "Work"
    case admin = "Admin"
    case exercise = "Exercise"
    case errand = "Errand"
    case personal = "Personal"

    var id: String {
        rawValue
    }

    var modelValue: Double {
        switch self {
        case .study:
            return 0
        case .coding:
            return 1
        case .work:
            return 2
        case .admin:
            return 3
        case .exercise:
            return 4
        case .errand:
            return 5
        case .personal:
            return 6
        }
    }
}
