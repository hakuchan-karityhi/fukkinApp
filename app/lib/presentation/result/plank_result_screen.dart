import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_result.dart";
import "../widgets/exp_gain_progress_bar.dart";

class PlankResultScreen extends ConsumerWidget {
  const PlankResultScreen({super.key, required this.result});

  static const _characterImageAsset = "assets/character/kangaru1.png";

  final PlankResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thresholds =
        ref.watch(gameConstantsProvider).valueOrNull?.levelThresholds ??
            const [150, 400, 800, 1400];
    final totalExpBefore = result.totalExpAfter - result.earnedExp;

    return Scaffold(
      appBar: AppBar(title: const Text("結果")),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                result.plankTypeName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "完了！",
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
                earnedExp: result.earnedExp,
                levelThresholds: thresholds,
              ),
              const SizedBox(height: 16),
              Text("基本EXP: ${result.baseExp}"),
              if (result.repeatSessionBonusPercent > 0)
                Text(
                  "再実施（${result.sessionIndexOfDay}回目 "
                  "+${result.repeatSessionBonusPercent}%）",
                ),
              if (result.dailyCapReached)
                Text(
                  "本日の獲得上限に達したため EXP が調整されました",
                  style: Theme.of(context).textTheme.bodySmall,
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
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Image.asset(
                    _characterImageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                "タップしてホームへ",
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
