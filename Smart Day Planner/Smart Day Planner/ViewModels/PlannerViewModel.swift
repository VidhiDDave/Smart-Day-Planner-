//
//  PlannerViewModel.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import Foundation
import Combine

@MainActor
final class PlannerViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var calendarEvents: [CalendarEvent] = []
    @Published var optimizedSchedule: [ScheduledTask] = []

    @Published var scheduleMessage: String?
    @Published var isLoadingTasks = false
    @Published var isLoadingCalendarEvents = false

    private var currentUserId: UUID?

    private let availabilityService = CalendarAvailabilityService()
    private let optimizer = ScheduleOptimizer()
    private let supabaseService = SupabaseService()
    private let googleCalendarService = GoogleCalendarService()

    func configureUser(_ userId: UUID) {
        guard currentUserId != userId else {
            return
        }

        currentUserId = userId
        clearPlannerData()

        Task {
            await loadTasks()
            await loadCalendarEvents()
        }
    }

    func clearUser() {
        currentUserId = nil
        clearPlannerData()
    }

    func loadTasks() async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        isLoadingTasks = true
        defer { isLoadingTasks = false }

        do {
            tasks = try await supabaseService.fetchTasks(for: currentUserId)
        } catch {
            scheduleMessage = "Unable to load tasks from Supabase. Using local tasks for now."
        }
    }

    func loadCalendarEvents() async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        isLoadingCalendarEvents = true
        defer { isLoadingCalendarEvents = false }

        do {
            calendarEvents = try await supabaseService.fetchCalendarEvents(for: currentUserId)
        } catch {
            scheduleMessage = "Unable to load calendar events from Supabase. Using local events for now."
        }
    }

    func addTask(
        title: String,
        durationMinutes: Int,
        priority: Int,
        deadline: Date,
        energyLevel: Int,
        category: TaskCategory
    ) {
        guard let currentUserId else {
            scheduleMessage = "Please sign in before adding tasks."
            return
        }

        let task = TaskItem(
            userId: currentUserId,
            title: title,
            durationMinutes: durationMinutes,
            priority: priority,
            deadline: deadline,
            energyLevel: energyLevel,
            category: category
        )

        tasks.append(task)

        Task {
            await saveTaskToSupabaseIfConfigured(task)
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        optimizedSchedule.removeAll { $0.taskId == task.id }

        Task {
            await deleteTaskFromSupabaseIfConfigured(task)
        }
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        tasks[index].isCompleted.toggle()
        let updatedTask = tasks[index]

        Task {
            await saveTaskToSupabaseIfConfigured(updatedTask)
        }
    }

    func addCalendarEvent(
        title: String,
        startDate: Date,
        endDate: Date
    ) {
        guard let currentUserId else {
            scheduleMessage = "Please sign in before adding calendar blocks."
            return
        }

        guard endDate > startDate else {
            scheduleMessage = "Calendar event end time must be after the start time."
            return
        }

        let event = CalendarEvent(
            userId: currentUserId,
            title: title,
            startDate: startDate,
            endDate: endDate
        )

        calendarEvents.append(event)

        Task {
            await saveCalendarEventToSupabaseIfConfigured(event)
        }
    }

    func deleteCalendarEvent(_ event: CalendarEvent) {
        calendarEvents.removeAll { $0.id == event.id }

        Task {
            await deleteCalendarEventFromSupabaseIfConfigured(event)
        }
    }

    func generateOptimizedSchedule() {
        let availableSlots = availabilityService.availableTimeSlots(
            for: calendarEvents
        )

        optimizedSchedule = optimizer.generateSchedule(
            tasks: tasks,
            calendarEvents: calendarEvents,
            availableSlots: availableSlots
        )

        if optimizedSchedule.isEmpty {
            scheduleMessage = "No tasks could be scheduled. Try adding more available time or adjusting deadlines."
        } else {
            scheduleMessage = "Generated \(optimizedSchedule.count) scheduled task(s)."
        }
    }

    func clearSchedule() {
        optimizedSchedule.removeAll()
        scheduleMessage = nil
    }

    private func clearPlannerData() {
        tasks.removeAll()
        calendarEvents.removeAll()
        optimizedSchedule.removeAll()
        scheduleMessage = nil
        isLoadingTasks = false
        isLoadingCalendarEvents = false
    }

    private func saveTaskToSupabaseIfConfigured(_ task: TaskItem) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.saveTask(task)
        } catch {
            scheduleMessage = "Task saved locally, but Supabase sync failed."
        }
    }

    private func deleteTaskFromSupabaseIfConfigured(_ task: TaskItem) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteTask(task)
        } catch {
            scheduleMessage = "Task deleted locally, but Supabase delete failed."
        }
    }

    private func saveCalendarEventToSupabaseIfConfigured(_ event: CalendarEvent) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.saveCalendarEvent(event)
        } catch {
            scheduleMessage = "Calendar block saved locally, but Supabase sync failed."
        }
    }

    private func deleteCalendarEventFromSupabaseIfConfigured(_ event: CalendarEvent) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteCalendarEvent(event)
        } catch {
            scheduleMessage = "Calendar block deleted locally, but Supabase delete failed."
        }
    }
    
    func importTodayGoogleCalendarEvents() async {
        guard let currentUserId else {
            scheduleMessage = "Please sign in before importing calendar events."
            return
        }

        do {
            let importedEvents = try await googleCalendarService.fetchTodayEvents(for: currentUserId)

            let newEvents = importedEvents.filter { importedEvent in
                !calendarEvents.contains { existingEvent in
                    existingEvent.externalEventId == importedEvent.externalEventId &&
                    existingEvent.source == importedEvent.source
                }
            }

            calendarEvents.append(contentsOf: newEvents)

            for event in newEvents {
                await saveCalendarEventToSupabaseIfConfigured(event)
            }

            if importedEvents.isEmpty {
                scheduleMessage = "Google Calendar returned 0 events for today."
            } else if newEvents.isEmpty {
                scheduleMessage = "Google Calendar returned \(importedEvents.count) event(s), but they were already imported."
            } else {
                scheduleMessage = "Imported \(newEvents.count) of \(importedEvents.count) Google Calendar event(s)."
            }
        } catch {
            scheduleMessage = error.localizedDescription
        }
    }
}
