//
//  OptimizedScheduleView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct OptimizedScheduleView: View {
    @ObservedObject var viewModel: PlannerViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if let message = viewModel.scheduleMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if viewModel.optimizedSchedule.isEmpty {
                        ContentUnavailableView(
                            "No Schedule Yet",
                            systemImage: "sparkles",
                            description: Text("Add tasks and calendar blocks, then generate an optimized schedule.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(viewModel.optimizedSchedule) { scheduledTask in
                            ScheduleCardView(scheduledTask: scheduledTask)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        viewModel.clearSchedule()
                    }
                    .disabled(viewModel.optimizedSchedule.isEmpty)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Optimized Day")
                .font(.title2)
                .fontWeight(.bold)

            Text("Generate a daily plan using your tasks, fixed calendar blocks, and ML-style task-time scoring.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.generateOptimizedSchedule()
            } label: {
                Label("Generate Schedule", systemImage: "wand.and.sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.tasks.isEmpty)
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
    viewModel.generateOptimizedSchedule()

    return OptimizedScheduleView(viewModel: viewModel)
}
