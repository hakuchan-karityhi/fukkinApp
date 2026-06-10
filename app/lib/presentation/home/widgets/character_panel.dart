import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/streak_state.dart";
import "../../../domain/models/user_progress.dart";
import "../../widgets/character_expression_view.dart";
import "../../widgets/dialogue_bubble.dart";

class CharacterPanel extends ConsumerWidget {
  const CharacterPanel({
    super.key,
    required this.progressAsync,
    required this.streakAsync,
  });

  final AsyncValue<UserProgress> progressAsync;
  final AsyncValue<StreakState> streakAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialoguesAsync = ref.watch(characterDialoguesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Icon(Icons.error_outline)),
        data: (progress) => streakAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error_outline)),
          data: (streak) => dialoguesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Icon(Icons.error_outline)),
            data: (master) {
              final selector = ref.watch(characterDialogueSelectorProvider);
              final dialogue = selector.homeDialogue(
                master: master,
                streak: streak,
                now: DateTime.now(),
              );
              final expressionKey =
                  selector.expressionKey(progress.absStage);
              final expression = master.expressions[expressionKey] ??
                  master.expressions["0"]!;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DialogueBubble(text: dialogue),
                    const SizedBox(height: 16),
                    CharacterExpressionView(
                      absStage: progress.absStage,
                      expression: expression,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      master.characterName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Lv ${progress.level}"),
                    Text("腹筋ステージ ${progress.absStage}"),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
