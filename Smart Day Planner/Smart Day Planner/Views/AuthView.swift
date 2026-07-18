//
//  AuthView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//
import SwiftUI

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
            }

            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Continue with Google", systemImage: "person.crop.circle.badge.checkmark")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .padding(.horizontal)

            Text("Google Sign-In is mocked for now. Real Supabase and Google authentication will be added in a later PR.")
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
