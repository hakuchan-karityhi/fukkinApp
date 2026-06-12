import "package:flutter/material.dart";

import "../../domain/models/milestone.dart";
import "../../domain/services/milestone_service.dart";

class MilestoneCelebration extends StatelessWidget {
  const MilestoneCelebration({
    super.key,
    required this.milestone,
    this.showTierLabel = false,
  });

  final MilestoneAchievement milestone;
  final bool showTierLabel;

  @override
  Widget build(BuildContext context) {
    final tier = const MilestoneService().celebrationTier(milestone.days);
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
          if (showTierLabel) ...[
            const SizedBox(height: 12),
            _TierChip(tier: tier),
          ],
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.tier});

  final MilestoneCelebrationTier tier;

  @override
  Widget build(BuildContext context) {
    final label = switch (tier) {
      MilestoneCelebrationTier.small => "小型演出",
      MilestoneCelebrationTier.medium => "中型演出",
      MilestoneCelebrationTier.large => "大型演出",
    };

    return Chip(
      avatar: Icon(
        switch (tier) {
          MilestoneCelebrationTier.small => Icons.celebration_outlined,
          MilestoneCelebrationTier.medium => Icons.emoji_events_outlined,
          MilestoneCelebrationTier.large => Icons.auto_awesome,
        },
        size: 18,
      ),
      label: Text(label),
    );
  }
}
