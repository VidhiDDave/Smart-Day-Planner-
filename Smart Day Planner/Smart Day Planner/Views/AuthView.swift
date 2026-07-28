//
//  AuthView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            VStack(spacing: 10) {
                Text("Smart Day Planner")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Plan your day with AI-powered scheduling around your tasks and calendar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if viewModel.isLoading {
                ProgressView("Signing in...")
            } else {
                GoogleSignInButton {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }
                .frame(height: 48)
                .padding(.horizontal)
            }

            Text("Real Google Sign-In UI is now wired. Supabase Auth token exchange will be added in a later PR.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
