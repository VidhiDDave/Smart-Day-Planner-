//
//  AppConfig.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

enum AppConfig {
    // These are placeholders for now.
    // Later, we will replace them with your real Supabase project URL and anon key.
    static let supabaseURL = "YOUR_SUPABASE_PROJECT_URL"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    // Placeholder for Google OAuth setup later.
    static let googleClientID = "YOUR_GOOGLE_CLIENT_ID"

    // Default day window used by the scheduler.
    // The app will try to schedule tasks between these hours.
    static let defaultDayStartHour = 8
    static let defaultDayEndHour = 22
}
