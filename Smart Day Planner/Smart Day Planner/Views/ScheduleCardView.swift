//
//  ScheduleCardView.swift
//  Smart Day Planner
//
//  Created by Vidhi Dave on 7/3/26.
//

import SwiftUI

struct ScheduleCardView: View {
    let scheduledTask: ScheduledTask

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timeRangeText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(scheduledTask.task?.title ?? "Scheduled Task")
                .font(.headline)

            Text(scheduledTask.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Score: \(Int(scheduledTask.score * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var timeRangeText: String {
        "\(scheduledTask.startDate.plannerTimeText) - \(scheduledTask.endDate.plannerTimeText)"
    }
}

#Preview {
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

    return ScheduleCardView(
        scheduledTask: ScheduledTask(
            userId: userId,
            taskId: task.id,
            task: task,
            startDate: .todayAt(hour: 10),
            endDate: .todayAt(hour: 12),
            score: 0.94,
            explanation: "Scheduled during a strong focus block before the deadline."
        )
    )
    .padding()
}
