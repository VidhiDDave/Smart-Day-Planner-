//
//  AddCalendarEventView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct AddCalendarEventView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var startDate = Date.todayAt(hour: 9)
    @State private var endDate = Date.todayAt(hour: 10)

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField("Event name", text: $title)

                    DatePicker(
                        "Start",
                        selection: $startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    DatePicker(
                        "End",
                        selection: $endDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                if endDate <= startDate {
                    Section {
                        Text("End time must be after start time.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Calendar Block")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }

    private func saveEvent() {
        viewModel.addCalendarEvent(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate
        )

        dismiss()
    }
}

#Preview {
    AddCalendarEventView(viewModel: PlannerViewModel())
}
