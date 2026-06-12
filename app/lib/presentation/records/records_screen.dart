import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../app/providers.dart";
import "../../domain/models/milestone.dart";
import "../../domain/models/streak_state.dart";
import "widgets/day_workout_list.dart";
import "widgets/milestone_target_editor.dart";
import "widgets/month_calendar.dart";

final _recordsMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final _selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final _monthWorkoutDatesProvider =
    FutureProvider.family<Set<DateTime>, DateTime>((ref, month) async {
  return ref.watch(workoutRepositoryProvider).getWorkoutDatesInMonth(
        month.year,
        month.month,
      );
});

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(_recordsMonthProvider);
    final selectedDate = ref.watch(_selectedDateProvider);
    final streakAsync = ref.watch(streakStateProvider);
    final targetsAsync = ref.watch(milestoneTargetsProvider);
    final achievementsAsync = ref.watch(milestoneAchievementsProvider);
    final workoutDatesAsync = ref.watch(_monthWorkoutDatesProvider(month));
    final dayRecordsAsync =
        ref.watch(workoutRecordsByDateProvider(selectedDate));
    final plankTypesAsync = ref.watch(plankTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("記録")),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(streakStateProvider);
          ref.invalidate(milestoneTargetsProvider);
          ref.invalidate(milestoneAchievementsProvider);
          ref.invalidate(_monthWorkoutDatesProvider(month));
          ref.invalidate(workoutRecordsByDateProvider(selectedDate));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            workoutDatesAsync.when(
              data: (dates) => MonthCalendar(
                year: month.year,
                month: month.month,
                workoutDates: dates,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(_selectedDateProvider.notifier).state = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                },
                onPreviousMonth: () {
                  ref.read(_recordsMonthProvider.notifier).state = DateTime(
                    month.year,
                    month.month - 1,
                  );
                },
                onNextMonth: () {
                  ref.read(_recordsMonthProvider.notifier).state = DateTime(
                    month.year,
                    month.month + 1,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text("カレンダーの読み込みに失敗: $error"),
            ),
            const SizedBox(height: 16),
            streakAsync.when(
              data: (streak) => _StreakSummaryCard(streak: streak),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            dayRecordsAsync.when(
              data: (records) => plankTypesAsync.when(
                data: (plankTypes) => DayWorkoutList(
                  selectedDate: selectedDate,
                  records: records,
                  plankTypeNames: {
                    for (final plank in plankTypes) plank.id: plank.name,
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Text("種目名の読み込みに失敗: $error"),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text("履歴の読み込みに失敗: $error"),
            ),
            const SizedBox(height: 16),
            targetsAsync.when(
              data: (targets) => achievementsAsync.when(
                data: (achievements) => streakAsync.when(
                  data: (streak) => MilestoneTargetEditor(
                    targets: targets,
                    achievements: achievements,
                    currentStreak: streak.currentStreak,
                    onAdd: (target) async {
                      await ref
                          .read(milestoneRepositoryProvider)
                          .addTarget(target);
                      ref.invalidate(milestoneTargetsProvider);
                    },
                    onRemove: (target) async {
                      await ref
                          .read(milestoneRepositoryProvider)
                          .removeTarget(target.days);
                      ref.invalidate(milestoneTargetsProvider);
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text("達成記録の読み込みに失敗: $error"),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text("目標の読み込みに失敗: $error"),
            ),
            const SizedBox(height: 16),
            achievementsAsync.when(
              data: (achievements) => _AchievementList(achievements: achievements),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakSummaryCard extends StatelessWidget {
  const _StreakSummaryCard({required this.streak});

  final StreakState streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "現在のストリーク",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    "${streak.currentStreak}日",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "最長ストリーク",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    "${streak.longestStreak}日",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementList extends StatelessWidget {
  const _AchievementList({required this.achievements});

  final List<MilestoneAchievement> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "まだ達成した称号はありません。目標を設定して、ストリークを続けましょう。",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "達成した称号",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final achievement in achievements.reversed) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.emoji_events),
                title: Text("${achievement.days}日 ${achievement.title}"),
                subtitle: Text(_formatDate(achievement.achievedAt)),
              ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return "${date.year}/${date.month}/${date.day}";
}
