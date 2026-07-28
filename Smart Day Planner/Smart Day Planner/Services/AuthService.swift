//
//  AuthService.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation
import GoogleSignIn
import UIKit

struct AuthSession {
    let userId: UUID
    let email: String
    let fullName: String?
    let avatarURL: String?
    let googleIdToken: String?
}

enum AuthServiceError: LocalizedError {
    case missingRootViewController
    case googleSignInNotConfigured
    case missingGoogleUser
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingRootViewController:
            return "Unable to find a root view controller for Google Sign-In."
        case .googleSignInNotConfigured:
            return "Google Sign-In is not configured yet."
        case .missingGoogleUser:
            return "Google Sign-In did not return a user."
        case .missingIDToken:
            return "Google Sign-In did not return an ID token."
        }
    }
}

final class AuthService {
    private(set) var currentSession: AuthSession?

    func restoreSession() async -> AuthSession? {
        await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                guard error == nil, let user else {
                    continuation.resume(returning: nil)
                    return
                }

                let session = self.makeSession(from: user)
                self.currentSession = session
                continuation.resume(returning: session)
            }
        }
    }

    func signInWithGoogle() async throws -> AuthSession {
        guard AppConfig.isGoogleSignInConfigured else {
            throw AuthServiceError.googleSignInNotConfigured
        }

        guard let presentingViewController = await MainActor.run(body: {
            UIApplication.shared.rootViewController
        }) else {
            throw AuthServiceError.missingRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        )

        let session = makeSession(from: result.user)
        currentSession = session

        return session
    }

    func signOut() async {
        GIDSignIn.sharedInstance.signOut()
        currentSession = nil
    }

    private func makeSession(from user: GIDGoogleUser) -> AuthSession {
        let userId = UUID(uuidString: user.userID ?? "") ?? MockUser.demoUserId

        return AuthSession(
            userId: userId,
            email: user.profile?.email ?? "unknown@gmail.com",
            fullName: user.profile?.name,
            avatarURL: user.profile?.imageURL(withDimension: 120)?.absoluteString,
            googleIdToken: user.idToken?.tokenString
        )
    }
}

private enum MockUser {
    static let demoUserId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
}

private extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
