//
//  CalendarBlocksView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct CalendarBlocksView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @State private var isShowingAddEvent = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.calendarEvents.isEmpty {
                    ContentUnavailableView(
                        "No Calendar Blocks",
                        systemImage: "calendar",
                        description: Text("Add fixed events like class, meetings, lunch, or work blocks.")
                    )
                } else {
                    ForEach(viewModel.calendarEvents.sorted { $0.startDate < $1.startDate }) { event in
                        eventRow(event)
                    }
                    .onDelete(perform: deleteEvents)
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddEvent) {
                AddCalendarEventView(viewModel: viewModel)
            }
        }
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.headline)

            Text("\(event.startDate.plannerTimeText) - \(event.endDate.plannerTimeText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(event.source.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func deleteEvents(at offsets: IndexSet) {
        let sortedEvents = viewModel.calendarEvents.sorted { $0.startDate < $1.startDate }

        for index in offsets {
            let event = sortedEvents[index]
            viewModel.deleteCalendarEvent(event)
        }
    }
}

#Preview {
    let viewModel = PlannerViewModel()
    viewModel.addCalendarEvent(
        title: "Class",
        startDate: .todayAt(hour: 9),
        endDate: .todayAt(hour: 10)
    )

    return CalendarBlocksView(viewModel: viewModel)
}
