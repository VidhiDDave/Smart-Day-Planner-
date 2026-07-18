//
//  AddTaskView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var durationMinutes = 60
    @State private var priority = 3
    @State private var deadline = Date.todayAt(hour: 18)
    @State private var energyLevel = 3
    @State private var category: TaskCategory = .study

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Task name", text: $title)

                    Stepper("Duration: \(durationMinutes) minutes", value: $durationMinutes, in: 15...480, step: 15)

                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("Scheduling Details") {
                    Stepper("Priority: \(priority)", value: $priority, in: 1...5)
                    Stepper("Energy level: \(energyLevel)", value: $energyLevel, in: 1...5)

                    DatePicker(
                        "Deadline",
                        selection: $deadline,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveTask() {
        viewModel.addTask(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            durationMinutes: durationMinutes,
            priority: priority,
            deadline: deadline,
            energyLevel: energyLevel,
            category: category
        )

        dismiss()
    }
}

#Preview {
    AddTaskView(viewModel: PlannerViewModel())
}
