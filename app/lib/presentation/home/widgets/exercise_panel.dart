import "package:flutter/material.dart";

import "../../../domain/models/plank_type.dart";
import "../../widgets/plank_pose_view.dart";
import "../../widgets/target_seconds_stepper.dart";

class PlankDetailPanel extends StatelessWidget {
  const PlankDetailPanel({
    super.key,
    required this.plank,
    required this.targetSeconds,
    required this.onTargetSecondsChanged,
  });

  final PlankType plank;
  final int targetSeconds;
  final ValueChanged<int> onTargetSecondsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 108),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlankPoseView(plankType: plank, size: 180, showLabel: false),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                plank.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              TargetSecondsStepper(
                seconds: targetSeconds,
                onChanged: onTargetSecondsChanged,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(child: _DifficultyStars(difficulty: plank.difficulty)),
          if (plank.isPerSide) ...[
            const SizedBox(height: 4),
            Text(
              "1側あたりの秒数（基本EXP）",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class CarouselIndicator extends StatelessWidget {
  const CarouselIndicator({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.onDotTap,
  });

  final int count;
  final int selectedIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${selectedIndex + 1} / $count",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(count, (index) {
                final selected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onDotTap(index),
                  child: Container(
                    width: selected ? 10 : 8,
                    height: selected ? 10 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeNavArrowButton extends StatelessWidget {
  const HomeNavArrowButton({super.key, required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon),
      ),
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < difficulty;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 18,
          color: filled ? Colors.orange : Colors.grey,
        );
      }),
    );
  }
}
