//
//  AppConfig.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

enum AppConfig {
    // Replace these placeholder values with your Supabase project values.
    // Supabase Dashboard → Project Settings → API
    static let supabaseURL = "YOUR_SUPABASE_PROJECT_URL"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    // Placeholder for Google OAuth setup later.
    static let googleClientID = "YOUR_GOOGLE_CLIENT_ID"

    static let defaultDayStartHour = 8
    static let defaultDayEndHour = 22

    static var isSupabaseConfigured: Bool {
        supabaseURL != "YOUR_SUPABASE_PROJECT_URL" &&
        supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY" &&
        URL(string: supabaseURL) != nil
    }
}
