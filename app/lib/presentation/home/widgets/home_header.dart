import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/streak_state.dart";
import "../../../domain/models/user_progress.dart";

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.progressAsync,
    required this.streakAsync,
  });

  final AsyncValue<UserProgress> progressAsync;
  final AsyncValue<StreakState> streakAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelService = ref.watch(levelServiceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          progressAsync.when(
            data: (progress) {
              if (levelService == null) {
                return const LinearProgressIndicator();
              }

              final thresholds =
                  ref.watch(gameConstantsProvider).valueOrNull?.levelThresholds ??
                      const [150, 400, 800, 1400];
              final nextThreshold = _nextThreshold(progress.totalExp, thresholds);
              final previousThreshold =
                  _previousThreshold(progress.totalExp, thresholds);
              final span = nextThreshold - previousThreshold;
              final currentInLevel = progress.totalExp - previousThreshold;
              final ratio = span == 0 ? 0.0 : currentInLevel / span;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lv ${progress.level}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text("$currentInLevel / $span"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      minHeight: 8,
                    ),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          streakAsync.when(
            data: (streak) {
              return Text("ストリーク${streak.currentStreak}日");
            },
            loading: () => const SizedBox(height: 20),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  int _nextThreshold(int totalExp, List<int> thresholds) {
    for (final threshold in thresholds) {
      if (totalExp < threshold) return threshold;
    }
    return thresholds.last + 100;
  }

  int _previousThreshold(int totalExp, List<int> thresholds) {
    var previous = 0;
    for (final threshold in thresholds) {
      if (totalExp < threshold) return previous;
      previous = threshold;
    }
    return previous;
  }
}
