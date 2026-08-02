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

        guard let googleSession = await authService.restoreSession(),
              let idToken = googleSession.googleIdToken else {
            return
        }

        do {
            try await supabaseService.signInWithGoogleIDToken(idToken)

            let userId = try await supabaseService.currentAuthenticatedUserId() ?? googleSession.userId
            let profile = makeProfile(from: googleSession, userId: userId)

            try await supabaseService.upsertProfile(profile)

            userProfile = profile
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            let googleSession = try await authService.signInWithGoogle()

            guard let idToken = googleSession.googleIdToken else {
                errorMessage = "Google did not return an ID token."
                isLoading = false
                return
            }

            try await supabaseService.signInWithGoogleIDToken(idToken)

            let userId = try await supabaseService.currentAuthenticatedUserId() ?? googleSession.userId
            let profile = makeProfile(from: googleSession, userId: userId)

            try await supabaseService.upsertProfile(profile)

            userProfile = profile
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }

        isLoading = false
    }

    func signOut() async {
        await authService.signOut()

        do {
            try await supabaseService.signOutFromSupabase()
        } catch {
            print("Supabase sign out skipped: \(error.localizedDescription)")
        }

        userProfile = nil
        isAuthenticated = false
    }

    private func makeProfile(from session: AuthSession, userId: UUID) -> UserProfile {
        UserProfile(
            id: userId,
            email: session.email,
            fullName: session.fullName,
            avatarURL: session.avatarURL,
            createdAt: Date()
        )
    }
}
