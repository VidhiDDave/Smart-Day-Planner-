//
//  AuthViewModel.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService()
    private let supabaseService = SupabaseService()

    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }

        if let session = await authService.restoreSession() {
            userProfile = makeProfile(from: session)
            isAuthenticated = true
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await authService.signInWithGoogle()
            let profile = makeProfile(from: session)

            try await supabaseService.upsertProfile(profile)

            userProfile = profile
            isAuthenticated = true
        } catch {
            errorMessage = "Unable to sign in. Please try again."
            isAuthenticated = false
        }

        isLoading = false
    }

    func signOut() async {
        await authService.signOut()
        userProfile = nil
        isAuthenticated = false
    }

    private func makeProfile(from session: AuthSession) -> UserProfile {
        UserProfile(
            id: session.userId,
            email: session.email,
            fullName: session.fullName,
            avatarURL: session.avatarURL,
            createdAt: Date()
        )
    }
}
