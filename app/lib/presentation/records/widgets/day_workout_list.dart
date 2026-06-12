import "package:flutter/material.dart";

import "../../../domain/models/workout_record.dart";

class DayWorkoutList extends StatelessWidget {
  const DayWorkoutList({
    super.key,
    required this.selectedDate,
    required this.records,
    required this.plankTypeNames,
  });

  final DateTime selectedDate;
  final List<WorkoutRecord> records;
  final Map<String, String> plankTypeNames;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        "${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "$dateLabelの記録",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Text(
                "この日は記録がありません",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              for (final record in records) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    plankTypeNames[record.plankTypeId] ?? record.plankTypeId,
                  ),
                  subtitle: Text(
                    "${record.targetSeconds}秒 · +${record.earnedExp} EXP · "
                    "${_formatTime(record.completedAt)} · "
                    "${record.sessionIndexOfDay}回目",
                  ),
                ),
                if (record != records.last) const Divider(height: 1),
              ],
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, "0");
  final minute = dateTime.minute.toString().padLeft(2, "0");
  return "$hour:$minute";
}
