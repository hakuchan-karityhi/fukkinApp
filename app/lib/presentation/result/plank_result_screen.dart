import "package:flutter/material.dart";

import "../../domain/models/milestone.dart";
import "../../domain/models/plank_result.dart";
import "../../domain/services/milestone_service.dart";

class PlankResultScreen extends StatelessWidget {
  const PlankResultScreen({super.key, required this.result});

  final PlankResult result;

  @override
  Widget build(BuildContext context) {
    final milestone = result.milestoneReached;
    final tier = milestone == null
        ? null
        : const MilestoneService().celebrationTier(milestone.days);

    return Scaffold(
      appBar: AppBar(title: const Text("結果")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.streakIncreased) ...[
              const Icon(Icons.local_fire_department, size: 64),
              Text(
                "ストリーク ${result.streakAfter}日！",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (milestone != null) ...[
              _MilestoneCelebration(milestone: milestone, tier: tier!),
              const SizedBox(height: 16),
            ],
            Text(
              result.plankTypeName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "+${result.earnedExp} EXP",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text("基本EXP: ${result.baseExp}"),
            Text("ストリーク: ${result.streakAfter}日"),
            if (result.levelUp)
              Text("レベルアップ！ Lv ${result.levelAfter}"),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("ホームへ"),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCelebration extends StatelessWidget {
  const _MilestoneCelebration({
    required this.milestone,
    required this.tier,
  });

  final MilestoneAchievement milestone;
  final MilestoneCelebrationTier tier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLarge = tier == MilestoneCelebrationTier.large;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLarge
              ? [
                  colorScheme.primaryContainer,
                  colorScheme.tertiaryContainer,
                ]
              : [
                  colorScheme.secondaryContainer,
                  colorScheme.primaryContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isLarge ? Icons.auto_awesome : Icons.emoji_events,
            size: isLarge ? 72 : 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            "マイルストーン達成！",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "${milestone.days}日",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            milestone.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
