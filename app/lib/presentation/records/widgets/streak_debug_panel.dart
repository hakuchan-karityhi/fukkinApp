import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/streak_state.dart";
import "../../debug/streak_debug_service.dart";

class StreakDebugPanel extends ConsumerStatefulWidget {
  const StreakDebugPanel({super.key});

  @override
  ConsumerState<StreakDebugPanel> createState() => _StreakDebugPanelState();
}

class _StreakDebugPanelState extends ConsumerState<StreakDebugPanel> {
  final _daysController = TextEditingController(text: "7");
  StreakDebugMode _mode = StreakDebugMode.nextCompletionReaches;
  bool _isApplying = false;

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final streakAsync = ref.watch(streakStateProvider);

    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  "デバッグ: ストリーク偽装",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "ストリーク日数を任意の値に設定して、ホーム表示やマイルストーン到達を検証できます。",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            streakAsync.when(
              data: (streak) => _CurrentStreakInfo(streak: streak),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _daysController,
              decoration: const InputDecoration(
                labelText: "日数 (X)",
                suffixText: "日",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            Text(
              "偽装モード",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in StreakDebugMode.values)
                  ChoiceChip(
                    label: Text(streakDebugModeLabel(mode)),
                    selected: _mode == mode,
                    onSelected: (_) => setState(() => _mode = mode),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isApplying ? null : () => _apply(context),
              icon: _isApplying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text("ストリークを適用"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    final days = int.tryParse(_daysController.text);
    if (days == null || days < 1 || days > 999) {
      _showMessage(context, "1〜999の日数を入力してください");
      return;
    }

    setState(() => _isApplying = true);
    try {
      final repository = ref.read(streakRepositoryProvider);
      final current = await repository.get();
      final fake = const StreakDebugService().buildFakeState(
        targetDays: days,
        mode: _mode,
        current: current,
      );

      await repository.save(fake);
      ref.invalidate(streakStateProvider);

      if (!context.mounted) return;
      _showMessage(
        context,
        _successMessage(days: days, fake: fake),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, "適用に失敗しました: $error");
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  String _successMessage({required int days, required StreakState fake}) {
    return switch (_mode) {
      StreakDebugMode.nextCompletionReaches =>
        "次の筋トレ完了で$days日目になります（現在: ${fake.currentStreak}日）",
      StreakDebugMode.ongoingNotDoneToday =>
        "ストリーク${fake.currentStreak}日（今日未実施）に設定しました",
      StreakDebugMode.ongoingDoneToday =>
        "ストリーク${fake.currentStreak}日（今日済み）に設定しました",
    };
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CurrentStreakInfo extends StatelessWidget {
  const _CurrentStreakInfo({required this.streak});

  final StreakState streak;

  @override
  Widget build(BuildContext context) {
    final todayStatus = streak.todayCompleted ? "今日済み" : "今日未実施";
    final lastWorkout = streak.lastWorkoutDate == null
        ? "なし"
        : "${streak.lastWorkoutDate!.year}/${streak.lastWorkoutDate!.month}/${streak.lastWorkoutDate!.day}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "現在: ストリーク${streak.currentStreak}日 / 最長${streak.longestStreak}日 / $todayStatus / 最終実施: $lastWorkout",
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
