import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/plank_type.dart";
import "../../../domain/models/streak_state.dart";
import "../../widgets/plank_pose_view.dart";

class PlankDetailPanel extends ConsumerWidget {
  const PlankDetailPanel({
    super.key,
    required this.plank,
    required this.targetSeconds,
    required this.streakAsync,
    required this.onTargetSecondsChanged,
  });

  final PlankType plank;
  final int targetSeconds;
  final AsyncValue<StreakState> streakAsync;
  final ValueChanged<int> onTargetSecondsChanged;

  static const _minSeconds = 10;
  static const _maxSeconds = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expCalculator = ref.watch(expCalculatorProvider);
    final streakService = ref.watch(streakServiceProvider);
    final todayWorkoutAsync = ref.watch(todayWorkoutSummaryProvider);

    final previewExp = streakAsync.maybeWhen(
      data: (streak) {
        if (expCalculator == null || streakService == null) return 0;
        final todayWorkout = todayWorkoutAsync.valueOrNull;
        final nextSessionIndex = (todayWorkout?.sessionCount ?? 0) + 1;
        final todayEarnedExp = todayWorkout?.earnedExpToday ?? 0;
        return expCalculator.calculate(
          baseExp: targetSeconds,
          difficultyMultiplier: plank.expMultiplier,
          streakMultiplier: streakService.getMultiplier(streak.currentStreak),
          sessionIndexOfDay: nextSessionIndex,
          todayEarnedExp: todayEarnedExp,
        );
      },
      orElse: () => 0,
    );

    final nextSessionIndex =
        (todayWorkoutAsync.valueOrNull?.sessionCount ?? 0) + 1;
    final repeatBonusPercent = expCalculator?.repeatSessionBonusPercent(
          nextSessionIndex,
        ) ??
        0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 108),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlankPoseView(plankType: plank, size: 180, showLabel: false),
          const SizedBox(height: 4),
          Text(
            plank.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
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
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "目標秒数",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    "$targetSeconds秒",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 16,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                ),
                child: Slider(
                  value: targetSeconds.toDouble(),
                  min: _minSeconds.toDouble(),
                  max: _maxSeconds.toDouble(),
                  divisions: _maxSeconds - _minSeconds,
                  label: "$targetSeconds秒",
                  onChanged: (value) =>
                      onTargetSecondsChanged(value.round()),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("完了時 EXP（見込み）"),
                    Text(
                      "+$previewExp",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (repeatBonusPercent > 0) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "再実施（$nextSessionIndex回目 +$repeatBonusPercent%）",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
