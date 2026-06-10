import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/workout_record.dart";

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(streakStateProvider);
    final recordsAsync =
        ref.watch(workoutRecordsForMonthProvider(_focusedMonth));
    final plankTypesAsync = ref.watch(plankTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("記録")),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("読み込みに失敗しました: $error")),
        data: (records) {
          final plankNameById = plankTypesAsync.maybeWhen(
            data: (types) => {
              for (final type in types) type.id: type.name,
            },
            orElse: () => <String, String>{},
          );

          final workoutDays = records
              .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
              .toSet();

          final dayRecords = records
              .where(
                (r) =>
                    r.date.year == _selectedDate.year &&
                    r.date.month == _selectedDate.month &&
                    r.date.day == _selectedDate.day,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              streakAsync.when(
                data: (streak) => _StreakSummaryCard(
                  currentStreak: streak.currentStreak,
                  longestStreak: streak.longestStreak,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              _MonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDate,
                workoutDays: workoutDays,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
                onDateSelected: _selectDate,
              ),
              const SizedBox(height: 20),
              _DayWorkoutList(
                date: _selectedDate,
                records: dayRecords,
                plankNameById: plankNameById,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StreakSummaryCard extends StatelessWidget {
  const _StreakSummaryCard({
    required this.currentStreak,
    required this.longestStreak,
  });

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _StreakStat(
                label: "現在のストリーク",
                value: "$currentStreak日",
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            Expanded(
              child: _StreakStat(
                label: "最長ストリーク",
                value: "$longestStreak日",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.focusedMonth,
    required this.selectedDate,
    required this.workoutDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<DateTime> workoutDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdayLabels = ["日", "月", "火", "水", "木", "金", "土"];

  @override
  Widget build(BuildContext context) {
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    "$year年$month月",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final label in _weekdayLabels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: label == "日"
                                ? Colors.red.shade400
                                : label == "土"
                                    ? Colors.blue.shade400
                                    : null,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }

                final day = index - firstWeekday + 1;
                final date = DateTime(year, month, day);
                final isSelected = _isSameDay(date, selectedDate);
                final isToday = _isSameDay(date, todayDate);
                final hasWorkout = workoutDays.contains(date);

                return _CalendarDayCell(
                  day: day,
                  isSelected: isSelected,
                  isToday: isToday,
                  hasWorkout: hasWorkout,
                  onTap: () => onDateSelected(date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasWorkout,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasWorkout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? background;
    Color? foreground;
    Border? border;

    if (isSelected) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
    } else if (isToday) {
      border = Border.all(color: colorScheme.primary, width: 2);
      foreground = colorScheme.primary;
    }

    return Material(
      color: background ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: border != null
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$day",
              style: TextStyle(
                fontWeight: isToday || isSelected ? FontWeight.bold : null,
                color: foreground,
              ),
            ),
            if (hasWorkout)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayWorkoutList extends StatelessWidget {
  const _DayWorkoutList({
    required this.date,
    required this.records,
    required this.plankNameById,
  });

  final DateTime date;
  final List<WorkoutRecord> records;
  final Map<String, String> plankNameById;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${date.year}年${date.month}月${date.day}日の記録",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "この日の記録はありません",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
          )
        else
          ...records.map(
            (record) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text("${record.sessionIndexOfDay}"),
                ),
                title: Text(
                  plankNameById[record.plankTypeId] ?? record.plankTypeId,
                ),
                subtitle: Text("${record.targetSeconds}秒"),
                trailing: Text(
                  "+${record.earnedExp} EXP",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
