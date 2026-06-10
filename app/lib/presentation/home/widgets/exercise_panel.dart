import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/plank_type.dart";
import "../../../domain/models/streak_state.dart";

class ExercisePanel extends ConsumerWidget {
  const ExercisePanel({
    super.key,
    required this.plank,
    required this.targetSeconds,
    required this.streakAsync,
    required this.onPrevious,
    required this.onNext,
    required this.onTargetSecondsChanged,
    required this.onStart,
  });

  final PlankType plank;
  final int targetSeconds;
  final AsyncValue<StreakState> streakAsync;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onTargetSecondsChanged;
  final VoidCallback onStart;

  static const _minSeconds = 10;
  static const _maxSeconds = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expCalculator = ref.watch(expCalculatorProvider);
    final streakService = ref.watch(streakServiceProvider);

    final previewExp = streakAsync.maybeWhen(
      data: (streak) {
        if (expCalculator == null || streakService == null) return 0;
        return expCalculator.calculate(
          baseExp: targetSeconds,
          difficultyMultiplier: plank.expMultiplier,
          streakMultiplier: streakService.getMultiplier(streak.currentStreak),
          isSecondSessionToday: streak.todayCompleted,
        );
      },
      orElse: () => 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  onPressed: onPrevious,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlankIllustration(plankType: plank),
                      const SizedBox(height: 12),
                      Text(
                        plank.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DifficultyStars(difficulty: plank.difficulty),
                          const SizedBox(width: 8),
                          _MultiplierBadge(multiplier: plank.expMultiplier),
                        ],
                      ),
                      if (plank.isPerSide) ...[
                        const SizedBox(height: 4),
                        Text(
                          "1側あたりの秒数（基本EXP）",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  onPressed: onNext,
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Text("目標秒数"),
              Expanded(
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
              Text("$targetSeconds秒"),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
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
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text("スタート"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlankIllustration extends StatelessWidget {
  const _PlankIllustration({required this.plankType});

  final PlankType plankType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.accessibility_new,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            plankType.id,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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

class _MultiplierBadge extends StatelessWidget {
  const _MultiplierBadge({required this.multiplier});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        "×${multiplier.toStringAsFixed(1)}",
        style: TextStyle(
          color: Colors.green.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.onPressed});

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
