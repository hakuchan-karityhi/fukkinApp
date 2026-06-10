import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../domain/models/user_progress.dart";

class CharacterPanel extends StatelessWidget {
  const CharacterPanel({
    super.key,
    required this.progressAsync,
  });

  final AsyncValue<UserProgress> progressAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: progressAsync.when(
          data: (progress) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                "かんちゃん",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Lv ${progress.level}"),
              Text("腹筋ステージ ${progress.absStage}"),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Icon(Icons.error_outline),
        ),
      ),
    );
  }
}
