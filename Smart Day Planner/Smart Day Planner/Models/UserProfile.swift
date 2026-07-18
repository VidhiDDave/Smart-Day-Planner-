//
//  UserProfile.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var email: String
    var fullName: String?
    var avatarURL: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
