import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../result/plank_result_screen.dart";
import "../result/streak_celebration_screen.dart";
import "plank_exercise_timer.dart";

class PlankSessionScreen extends ConsumerWidget {
  const PlankSessionScreen({
    super.key,
    required this.plankType,
    required this.targetSeconds,
  });

  final PlankType plankType;
  final int targetSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: PlankExerciseTimer(
          plankType: plankType,
          targetSeconds: targetSeconds,
          onExitConfirmed: () => Navigator.of(context).pop(),
          onTimerComplete: () async {
            final useCase = ref.read(completePlankUseCaseProvider);
            if (useCase == null) {
              throw StateError("CompletePlankUseCase is not ready");
            }

            final result = await useCase.execute(
              plankTypeId: plankType.id,
              targetSeconds: targetSeconds,
            );

            if (!context.mounted) return;

            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => StreakCelebrationScreen(
                  streakAfter: result.streakAfter,
                  streakIncreased: result.streakIncreased,
                  nextScreen: PlankResultScreen(result: result),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
