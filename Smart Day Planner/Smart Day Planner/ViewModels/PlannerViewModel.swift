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
            await loadScheduledTasks()
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
            calendarEvents = try await supabaseService.fetchCalendarEvents(
                for: currentUserId
            )
        } catch {
            scheduleMessage = "Unable to load calendar events from Supabase. Using local events for now."
        }
    }

    func loadScheduledTasks() async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        do {
            optimizedSchedule = try await supabaseService.fetchScheduledTasks(
                for: currentUserId
            )
        } catch {
            scheduleMessage = "Unable to load saved schedule from Supabase."
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
        let scheduledTask = optimizedSchedule.first {
            $0.taskId == task.id
        }

        tasks.removeAll { $0.id == task.id }
        optimizedSchedule.removeAll { $0.taskId == task.id }

        Task {
            if let scheduledTask {
                await recordTaskPlacementFeedback(
                    task: task,
                    scheduledTask: scheduledTask,
                    type: .skipped,
                    targetScore: 0.15
                )
            }

            await deleteTaskFromSupabaseIfConfigured(task)
            await syncScheduleToSupabaseIfConfigured()
        }
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let scheduledTask = optimizedSchedule.first {
            $0.taskId == task.id
        }

        tasks[index].isCompleted.toggle()
        let updatedTask = tasks[index]

        if updatedTask.isCompleted {
            optimizedSchedule.removeAll {
                $0.taskId == updatedTask.id
            }
        }

        Task {
            await saveTaskToSupabaseIfConfigured(updatedTask)

            if updatedTask.isCompleted {
                if let scheduledTask {
                    await recordTaskPlacementFeedback(
                        task: updatedTask,
                        scheduledTask: scheduledTask,
                        type: .completed,
                        targetScore: 1.0
                    )
                }

                await syncScheduleToSupabaseIfConfigured()
            }
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
        invalidateScheduleAfterCalendarChange()

        Task {
            await saveCalendarEventToSupabaseIfConfigured(event)
            await deleteScheduledTasksFromSupabaseIfConfigured()
        }
    }

    func deleteCalendarEvent(_ event: CalendarEvent) {
        calendarEvents.removeAll { $0.id == event.id }
        invalidateScheduleAfterCalendarChange()

        Task {
            await deleteCalendarEventFromSupabaseIfConfigured(event)
            await deleteScheduledTasksFromSupabaseIfConfigured()
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

        Task {
            await syncScheduleToSupabaseIfConfigured()
        }
    }

    func rescheduleTask(
        _ scheduledTask: ScheduledTask,
        to newStartDate: Date
    ) -> Bool {
        guard let index = optimizedSchedule.firstIndex(
            where: { $0.id == scheduledTask.id }
        ) else {
            scheduleMessage = "Unable to find the scheduled task."
            return false
        }

        guard let task = tasks.first(
            where: { $0.id == scheduledTask.taskId }
        ) ?? scheduledTask.task else {
            scheduleMessage = "Unable to find the original task."
            return false
        }

        let duration = scheduledTask.endDate.timeIntervalSince(
            scheduledTask.startDate
        )

        let newEndDate = newStartDate.addingTimeInterval(duration)

        guard newEndDate <= task.deadline else {
            scheduleMessage = "The task cannot be moved past its deadline."
            return false
        }

        let overlapsCalendarEvent = calendarEvents.contains { event in
            datesOverlap(
                startDate: newStartDate,
                endDate: newEndDate,
                otherStartDate: event.startDate,
                otherEndDate: event.endDate
            )
        }

        guard !overlapsCalendarEvent else {
            scheduleMessage = "That time conflicts with a calendar event."
            return false
        }

        let overlapsScheduledTask = optimizedSchedule.contains { otherTask in
            guard otherTask.id != scheduledTask.id else {
                return false
            }

            return datesOverlap(
                startDate: newStartDate,
                endDate: newEndDate,
                otherStartDate: otherTask.startDate,
                otherEndDate: otherTask.endDate
            )
        }

        guard !overlapsScheduledTask else {
            scheduleMessage = "That time conflicts with another scheduled task."
            return false
        }

        let originalScheduledTask = optimizedSchedule[index]

        optimizedSchedule[index].startDate = newStartDate
        optimizedSchedule[index].endDate = newEndDate
        optimizedSchedule[index].explanation = "Moved to your preferred time."

        let updatedScheduledTask = optimizedSchedule[index]

        scheduleMessage = "Task moved to \(newStartDate.plannerTimeText)."

        Task {
            await recordMovedTaskPlacementFeedback(
                task: task,
                originalScheduledTask: originalScheduledTask,
                updatedScheduledTask: updatedScheduledTask
            )

            await syncScheduleToSupabaseIfConfigured()
        }

        return true
    }

    func clearSchedule() {
        optimizedSchedule.removeAll()
        scheduleMessage = nil

        Task {
            await deleteScheduledTasksFromSupabaseIfConfigured()
        }
    }

    private func clearPlannerData() {
        tasks.removeAll()
        calendarEvents.removeAll()
        optimizedSchedule.removeAll()
        scheduleMessage = nil
        isLoadingTasks = false
        isLoadingCalendarEvents = false
    }

    private func invalidateScheduleAfterCalendarChange() {
        guard !optimizedSchedule.isEmpty else {
            return
        }

        optimizedSchedule.removeAll()
        scheduleMessage = "Calendar changed. Regenerate your schedule to update task times."
    }

    private func datesOverlap(
        startDate: Date,
        endDate: Date,
        otherStartDate: Date,
        otherEndDate: Date
    ) -> Bool {
        startDate < otherEndDate &&
        endDate > otherStartDate
    }

    private func saveTaskToSupabaseIfConfigured(
        _ task: TaskItem
    ) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.saveTask(task)
        } catch {
            scheduleMessage = "Task saved locally, but Supabase sync failed."
        }
    }

    private func deleteTaskFromSupabaseIfConfigured(
        _ task: TaskItem
    ) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteTask(task)
        } catch {
            scheduleMessage = "Task deleted locally, but Supabase delete failed."
        }
    }

    private func saveCalendarEventToSupabaseIfConfigured(
        _ event: CalendarEvent
    ) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.saveCalendarEvent(event)
        } catch {
            scheduleMessage = "Calendar block saved locally, but Supabase sync failed."
        }
    }

    private func deleteCalendarEventFromSupabaseIfConfigured(
        _ event: CalendarEvent
    ) async {
        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteCalendarEvent(event)
        } catch {
            scheduleMessage = "Calendar block deleted locally, but Supabase delete failed."
        }
    }

    private func recordTaskPlacementFeedback(
        task: TaskItem,
        scheduledTask: ScheduledTask,
        type: TaskPlacementFeedbackType,
        targetScore: Double,
        actualStartDate: Date? = nil
    ) async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        let slot = TimeSlot(
            startDate: scheduledTask.startDate,
            endDate: scheduledTask.endDate
        )

        let features = TaskPlacementFeatures(
            task: task,
            slot: slot
        )

        let feedback = TaskPlacementFeedback(
            userId: currentUserId,
            taskId: task.id,
            features: features,
            suggestedStartDate: scheduledTask.startDate,
            actualStartDate: actualStartDate,
            feedbackType: type,
            targetScore: targetScore
        )

        do {
            try await supabaseService.saveTaskPlacementFeedback(
                feedback
            )
        } catch {
            scheduleMessage = "Task updated, but learning feedback could not be saved."
        }
    }

    private func recordMovedTaskPlacementFeedback(
        task: TaskItem,
        originalScheduledTask: ScheduledTask,
        updatedScheduledTask: ScheduledTask
    ) async {
        await recordTaskPlacementFeedback(
            task: task,
            scheduledTask: originalScheduledTask,
            type: .moved,
            targetScore: 0.20,
            actualStartDate: updatedScheduledTask.startDate
        )

        await recordTaskPlacementFeedback(
            task: task,
            scheduledTask: updatedScheduledTask,
            type: .accepted,
            targetScore: 1.0,
            actualStartDate: updatedScheduledTask.startDate
        )
    }

    private func syncScheduleToSupabaseIfConfigured() async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteScheduledTasks(
                for: currentUserId
            )

            if !optimizedSchedule.isEmpty {
                try await supabaseService.saveScheduledTasks(
                    optimizedSchedule
                )
            }
        } catch {
            scheduleMessage = "Schedule updated locally, but Supabase sync failed."
        }
    }

    private func deleteScheduledTasksFromSupabaseIfConfigured() async {
        guard let currentUserId else {
            return
        }

        guard supabaseService.isConfigured else {
            return
        }

        do {
            try await supabaseService.deleteScheduledTasks(
                for: currentUserId
            )
        } catch {
            scheduleMessage = "Schedule cleared locally, but Supabase delete failed."
        }
    }

    func importTodayGoogleCalendarEvents() async {
        guard let currentUserId else {
            scheduleMessage = "Please sign in before importing calendar events."
            return
        }

        do {
            let importedEvents = try await googleCalendarService.fetchTodayEvents(
                for: currentUserId
            )

            let newEvents = importedEvents.filter { importedEvent in
                !calendarEvents.contains { existingEvent in
                    existingEvent.externalEventId == importedEvent.externalEventId &&
                    existingEvent.source == importedEvent.source
                }
            }

            calendarEvents.append(contentsOf: newEvents)

            for event in newEvents {
                await saveCalendarEventToSupabaseIfConfigured(
                    event
                )
            }

            if !newEvents.isEmpty {
                invalidateScheduleAfterCalendarChange()
                await deleteScheduledTasksFromSupabaseIfConfigured()
            }

            if importedEvents.isEmpty {
                scheduleMessage = "Google Calendar returned 0 events for today."
            } else if newEvents.isEmpty {
                scheduleMessage = "Google Calendar returned \(importedEvents.count) event(s), but they were already imported."
            } else {
                scheduleMessage = "Imported \(newEvents.count) of \(importedEvents.count) Google Calendar event(s). Regenerate your schedule to update task times."
            }
        } catch {
            scheduleMessage = error.localizedDescription
        }
    }
}
