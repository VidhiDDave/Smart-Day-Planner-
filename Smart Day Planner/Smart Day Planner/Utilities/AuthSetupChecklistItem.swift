//
//  AuthSetupChecklistItem.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/2/26.
//

import Foundation

struct AuthSetupChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let isComplete: Bool
}

enum AuthSetupChecklist {
    static var items: [AuthSetupChecklistItem] {
        [
            AuthSetupChecklistItem(
                title: "Supabase project URL",
                detail: "Add the Supabase project URL in AppConfig.",
                isComplete: AppConfig.isSupabaseConfigured
            ),
            AuthSetupChecklistItem(
                title: "Supabase anon key",
                detail: "Add the public anon key from Supabase project settings.",
                isComplete: AppConfig.isSupabaseConfigured
            ),
            AuthSetupChecklistItem(
                title: "Google iOS client ID",
                detail: "Add the iOS OAuth client ID from Google Cloud.",
                isComplete: AppConfig.isGoogleSignInConfigured
            ),
            AuthSetupChecklistItem(
                title: "Google server client ID",
                detail: "Add the web/server OAuth client ID for Supabase Auth.",
                isComplete: AppConfig.isGoogleSignInConfigured
            ),
            AuthSetupChecklistItem(
                title: "URL scheme",
                detail: "Add the reversed Google client ID as an app URL scheme.",
                isComplete: AppConfig.isGoogleSignInConfigured
            ),
            AuthSetupChecklistItem(
                title: "Supabase Google provider",
                detail: "Enable Google as an auth provider in the Supabase dashboard.",
                isComplete: false
            )
        ]
    }
}
