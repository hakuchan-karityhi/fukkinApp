import "package:flutter/material.dart";

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.workoutDates,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final int year;
  final int month;
  final Set<DateTime> workoutDates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "$year年$month月",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: Center(child: Text("日"))),
                Expanded(child: Center(child: Text("月"))),
                Expanded(child: Center(child: Text("火"))),
                Expanded(child: Center(child: Text("水"))),
                Expanded(child: Center(child: Text("木"))),
                Expanded(child: Center(child: Text("金"))),
                Expanded(child: Center(child: Text("土"))),
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
              itemCount: ((daysInMonth + startWeekday + 6) ~/ 7) * 7,
              itemBuilder: (context, index) {
                final day = index - startWeekday + 1;
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(year, month, day);
                final hasWorkout = workoutDates.any(
                  (workoutDate) => isSameDay(workoutDate, date),
                );
                final isSelected = isSameDay(selectedDate, date);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onDateSelected(date),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : hasWorkout
                                ? colorScheme.primaryContainer
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Text(
                        "$day",
                        style: TextStyle(
                          fontWeight: hasWorkout || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : hasWorkout
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
