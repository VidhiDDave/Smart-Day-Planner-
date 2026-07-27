//
//  AppConfig.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation

enum AppConfig {
    // Supabase Dashboard → Project Settings → API
    static let supabaseURL = "YOUR_SUPABASE_PROJECT_URL"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    // Google Cloud Console → OAuth 2.0 Client IDs
    static let googleIOSClientID = "YOUR_GOOGLE_IOS_CLIENT_ID"
    static let googleServerClientID = "YOUR_GOOGLE_SERVER_CLIENT_ID"
    static let googleReversedClientID = "YOUR_GOOGLE_REVERSED_CLIENT_ID"

    static let defaultDayStartHour = 8
    static let defaultDayEndHour = 22

    static var isSupabaseConfigured: Bool {
        supabaseURL != "YOUR_SUPABASE_PROJECT_URL" &&
        supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY" &&
        URL(string: supabaseURL) != nil
    }

    static var isGoogleSignInConfigured: Bool {
        googleIOSClientID != "YOUR_GOOGLE_IOS_CLIENT_ID" &&
        googleServerClientID != "YOUR_GOOGLE_SERVER_CLIENT_ID" &&
        googleReversedClientID != "YOUR_GOOGLE_REVERSED_CLIENT_ID"
    }
}
