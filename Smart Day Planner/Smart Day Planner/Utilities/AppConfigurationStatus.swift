//
//  AppConfigurationStatus.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/29/26.
//

import Foundation

struct AppConfigurationStatus {
    let isSupabaseConfigured: Bool
    let isGoogleSignInConfigured: Bool

    var supabaseStatusText: String {
        isSupabaseConfigured ? "Configured" : "Not configured"
    }

    var googleSignInStatusText: String {
        isGoogleSignInConfigured ? "Configured" : "Not configured"
    }

    var isReadyForRealAuth: Bool {
        isSupabaseConfigured && isGoogleSignInConfigured
    }

    static var current: AppConfigurationStatus {
        AppConfigurationStatus(
            isSupabaseConfigured: AppConfig.isSupabaseConfigured,
            isGoogleSignInConfigured: AppConfig.isGoogleSignInConfigured
        )
    }
}
