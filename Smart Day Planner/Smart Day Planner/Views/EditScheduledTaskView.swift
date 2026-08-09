//
//  EditScheduledTaskView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 8/8/26.
//

import SwiftUI

struct EditScheduledTaskView: View {
    let scheduledTask: ScheduledTask

    @ObservedObject var viewModel: PlannerViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedStartDate: Date
    @State private var validationMessage: String?

    init(
        scheduledTask: ScheduledTask,
        viewModel: PlannerViewModel
    ) {
        self.scheduledTask = scheduledTask
        self.viewModel = viewModel

        _selectedStartDate = State(
            initialValue: scheduledTask.startDate
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    Text(
                        scheduledTask.task?.title ??
                        taskTitle
                    )

                    LabeledContent(
                        "Duration",
                        value: "\(scheduledTask.durationMinutes) min"
                    )

                    LabeledContent(
                        "Current time",
                        value: currentTimeRange
                    )
                }

                Section("New Time") {
                    DatePicker(
                        "Start",
                        selection: $selectedStartDate,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )

                    LabeledContent(
                        "New end time",
                        value: newEndDate.plannerTimeText
                    )
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Text(
                        "Moving a task teaches the planner which times you prefer. The task duration stays the same."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Move Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        save()
                    }
                    .disabled(
                        selectedStartDate ==
                        scheduledTask.startDate
                    )
                }
            }
        }
    }

    private var taskTitle: String {
        viewModel.tasks.first {
            $0.id == scheduledTask.taskId
        }?.title ?? "Scheduled Task"
    }

    private var currentTimeRange: String {
        "\(scheduledTask.startDate.plannerTimeText) - \(scheduledTask.endDate.plannerTimeText)"
    }

    private var newEndDate: Date {
        selectedStartDate.addingTimeInterval(
            TimeInterval(
                scheduledTask.durationMinutes * 60
            )
        )
    }

    private func save() {
        validationMessage = nil

        let didReschedule = viewModel.rescheduleTask(
            scheduledTask,
            to: selectedStartDate
        )

        if didReschedule {
            dismiss()
        } else {
            validationMessage =
                viewModel.scheduleMessage ??
                "Unable to move the task."
        }
    }
}

#Preview {
    let viewModel = PlannerViewModel()
    let userId = UUID()

    let task = TaskItem(
        userId: userId,
        title: "Finish CS assignment",
        durationMinutes: 120,
        priority: 5,
        deadline: .todayAt(hour: 22),
        energyLevel: 5,
        category: .study
    )

    let scheduledTask = ScheduledTask(
        userId: userId,
        taskId: task.id,
        task: task,
        startDate: .todayAt(hour: 10),
        endDate: .todayAt(hour: 12),
        score: 0.94,
        explanation: "Scheduled during a strong focus block before the deadline."
    )

    return EditScheduledTaskView(
        scheduledTask: scheduledTask,
        viewModel: viewModel
    )
}
