//
//  AuthService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation

struct AuthSession {
    let userId: UUID
    let email: String
    let fullName: String?
    let avatarURL: String?
}

final class AuthService {
    private(set) var currentSession: AuthSession?

    func restoreSession() async -> AuthSession? {
        // Real Supabase session restore will be added later.
        currentSession
    }

    func signInWithGoogle() async throws -> AuthSession {
        // Temporary mock Google login.
        // Later this will use Google Sign-In and Supabase Auth.
        let session = AuthSession(
            userId: MockUser.demoUserId,
            email: "demo.user@gmail.com",
            fullName: "Demo User",
            avatarURL: nil
        )

        currentSession = session
        return session
    }

    func signOut() async {
        // Real Supabase sign-out will be added later.
        currentSession = nil
    }
}

private enum MockUser {
    static let demoUserId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
}
