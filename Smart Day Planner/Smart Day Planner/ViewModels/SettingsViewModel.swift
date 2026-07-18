//
//  SettingViewModel.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/18/26.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isGoogleCalendarConnected = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let googleCalendarService = GoogleCalendarService()

    func connectGoogleCalendar() async {
        isLoading = true
        errorMessage = nil

        do {
            try await googleCalendarService.connectCalendar()
            isGoogleCalendarConnected = true
        } catch {
            errorMessage = "Unable to connect Google Calendar."
        }

        isLoading = false
    }

    func disconnectGoogleCalendar() async {
        isLoading = true
        await googleCalendarService.disconnectCalendar()
        isGoogleCalendarConnected = false
        isLoading = false
    }
}
