import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../../domain/models/milestone.dart";
import "../../../domain/services/milestone_service.dart";
import "../../debug/milestone_celebration_preview_screen.dart";

class MilestoneDebugPanel extends StatelessWidget {
  const MilestoneDebugPanel({
    super.key,
    required this.targets,
  });

  final List<MilestoneTarget> targets;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final tierSamples = [
      const MilestoneTarget(days: 3, title: "習慣の芽", isBuiltin: true),
      const MilestoneTarget(days: 7, title: "1週間の相棒", isBuiltin: true),
      const MilestoneTarget(days: 14, title: "2週間マスター", isBuiltin: true),
      const MilestoneTarget(days: 30, title: "継続の証", isBuiltin: true),
      const MilestoneTarget(days: 60, title: "習慣の達人", isBuiltin: true),
      const MilestoneTarget(days: 100, title: "レジェンド", isBuiltin: true),
    ];

    const service = MilestoneService();

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
                  "デバッグ: 演出プレビュー",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "マイルストーン達成時の結果画面演出を確認できます。達成記録は保存されません。",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              "演出ティア別サンプル",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sample in tierSamples)
                  _PreviewChip(
                    label: "${sample.days}日",
                    tier: service.celebrationTier(sample.days),
                    onPressed: () => _preview(context, sample),
                  ),
              ],
            ),
            if (targets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "登録中の目標",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final target in targets)
                    ActionChip(
                      label: Text("${target.days}日 ${target.title}"),
                      onPressed: () => _preview(context, target),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _preview(BuildContext context, MilestoneTarget target) {
    openMilestoneCelebrationPreview(
      context,
      milestone: MilestoneAchievement(
        days: target.days,
        title: target.title,
        achievedAt: DateTime.now(),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.label,
    required this.tier,
    required this.onPressed,
  });

  final String label;
  final MilestoneCelebrationTier tier;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tierLabel = switch (tier) {
      MilestoneCelebrationTier.small => "小",
      MilestoneCelebrationTier.medium => "中",
      MilestoneCelebrationTier.large => "大",
    };

    return ActionChip(
      avatar: CircleAvatar(
        radius: 10,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          tierLabel,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
