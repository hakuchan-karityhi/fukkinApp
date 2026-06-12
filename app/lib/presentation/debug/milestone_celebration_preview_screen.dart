import "package:flutter/material.dart";

import "../../domain/models/milestone.dart";
import "../widgets/milestone_celebration.dart";

/// マイルストーン達成時の結果画面（SC-08）演出を確認するためのプレビュー。
class MilestoneCelebrationPreviewScreen extends StatelessWidget {
  const MilestoneCelebrationPreviewScreen({
    super.key,
    required this.milestone,
    this.streakAfter,
  });

  final MilestoneAchievement milestone;
  final int? streakAfter;

  @override
  Widget build(BuildContext context) {
    final streak = streakAfter ?? milestone.days;

    return Scaffold(
      appBar: AppBar(
        title: const Text("演出プレビュー"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "デバッグ用プレビュー（実際の達成記録には影響しません）",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.local_fire_department, size: 64),
            Text(
              "ストリーク $streak日！",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            MilestoneCelebration(
              milestone: milestone,
              showTierLabel: true,
            ),
            const SizedBox(height: 16),
            Text(
              "ベーシックプランク",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "+30 EXP",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("閉じる"),
            ),
          ],
        ),
      ),
    );
  }
}

void openMilestoneCelebrationPreview(
  BuildContext context, {
  required MilestoneAchievement milestone,
  int? streakAfter,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MilestoneCelebrationPreviewScreen(
        milestone: milestone,
        streakAfter: streakAfter,
      ),
    ),
  );
}
