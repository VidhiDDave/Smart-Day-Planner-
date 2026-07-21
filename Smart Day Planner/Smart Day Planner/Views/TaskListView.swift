//
//  TaskListView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @State private var isShowingAddTask = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoadingTasks {
                    ProgressView("Loading tasks...")
                } else if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks Yet",
                        systemImage: "checklist",
                        description: Text("Add tasks you want the planner to schedule.")
                    )
                } else {
                    ForEach(viewModel.tasks) { task in
                        taskRow(task)
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadTasks()
            }
        }
    }

    private func taskRow(_ task: TaskItem) -> some View {
        Button {
            viewModel.toggleTaskCompletion(task)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .green : .secondary)

                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)

                    Spacer()

                    Text(task.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }

                Text("\(task.durationMinutes) min • Priority \(task.priority) • Energy \(task.energyLevel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Due \(task.deadline.plannerTimeText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = viewModel.tasks[index]
            viewModel.deleteTask(task)
        }
    }
}

#Preview {
    let viewModel = PlannerViewModel()
    viewModel.addTask(
        title: "Finish CS assignment",
        durationMinutes: 120,
        priority: 5,
        deadline: .todayAt(hour: 22),
        energyLevel: 5,
        category: .study
    )

    return TaskListView(viewModel: viewModel)
}
