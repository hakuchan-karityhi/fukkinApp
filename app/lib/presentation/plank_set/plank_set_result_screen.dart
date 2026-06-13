import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_set.dart";
import "../result/streak_celebration_screen.dart";
import "../widgets/exp_gain_progress_bar.dart";

class PlankSetResultScreen extends ConsumerWidget {
  const PlankSetResultScreen({super.key, required this.result});

  final PlankSetResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thresholds =
        ref.watch(gameConstantsProvider).valueOrNull?.levelThresholds ??
            const [150, 400, 800, 1400];
    final totalExpBefore = result.totalExpAfter - result.totalEarnedExp;

    return Scaffold(
      appBar: AppBar(title: const Text("セット結果")),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openStreakCelebrationScreen(
          context,
          streakAfter: result.streakAfter,
          streakIncreased: result.streakIncreased,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                result.setName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "セット完了！",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ExpGainProgressBar(
                totalExpBefore: totalExpBefore,
                totalExpAfter: result.totalExpAfter,
                earnedExp: result.totalEarnedExp,
                levelThresholds: thresholds,
              ),
              const SizedBox(height: 16),
              for (final plankResult in result.plankResults)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "${plankResult.plankTypeName}: +${plankResult.earnedExp} EXP",
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "合計: +${result.totalEarnedExp} EXP",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (result.levelUp)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "レベルアップ！ Lv ${result.levelAfter}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Spacer(),
              Text(
                "タップして続ける",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
