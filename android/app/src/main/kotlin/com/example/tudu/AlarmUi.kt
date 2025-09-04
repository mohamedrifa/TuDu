package com.example.tudu

import android.content.Context

object AlarmUi {
    fun showBeforeLoud(ctx: Context, task: TaskRow) {
        FullScreenNotifier.show(
            ctx = ctx,
            title = "Reminder",
            text = "Loud: ${task.title}",
            route = "/lockscreen", // or a more specific route if you like
            extras = mapOf(
                "alarm_kind" to "before",
                "task_id" to task.id,
                "task_title" to task.title
            ),
            notifId = 7000 + (task.idBase % 900000)
        )
    }

    fun showAfterLoud(ctx: Context, task: TaskRow) {
        FullScreenNotifier.show(
            ctx = ctx,
            title = "Reminder",
            text = "Overdue: ${task.title}",
            route = "/lockscreen",
            extras = mapOf(
                "alarm_kind" to "after",
                "task_id" to task.id,
                "task_title" to task.title
            ),
            notifId = 8000 + (task.idBase % 900000)
        )
    }
}
