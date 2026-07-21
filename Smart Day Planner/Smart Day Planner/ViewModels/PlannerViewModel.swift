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

    // Temporary user ID until real Google login + Supabase auth is added.
    // Later this will come from the logged-in Supabase user.
    let currentUserId = UUID()

    private let availabilityService = CalendarAvailabilityService()
    private let optimizer = ScheduleOptimizer()
    private let supabaseService = SupabaseService()

    func loadTasks() async {
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

    func addTask(
        title: String,
        durationMinutes: Int,
        priority: Int,
        deadline: Date,
        energyLevel: Int,
        category: TaskCategory
    ) {
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
    }

    func deleteCalendarEvent(_ event: CalendarEvent) {
        calendarEvents.removeAll { $0.id == event.id }
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
}
