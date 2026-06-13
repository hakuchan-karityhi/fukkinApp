import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/streak_state.dart";
import "../../../domain/models/user_progress.dart";

class CharacterPanel extends ConsumerWidget {
  const CharacterPanel({
    super.key,
    required this.progressAsync,
    required this.streakAsync,
  });

  final AsyncValue<UserProgress> progressAsync;
  final AsyncValue<StreakState> streakAsync;

  static const _characterImageAsset = "assets/character/kangaru1.png";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialoguesAsync = ref.watch(characterDialoguesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Icon(Icons.error_outline)),
        data: (_) => streakAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Icon(Icons.error_outline)),
          data: (_) => dialoguesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Icon(Icons.error_outline)),
            data: (master) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _characterImageAsset,
                      height: 380,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      master.characterName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
