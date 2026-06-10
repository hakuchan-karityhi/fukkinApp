import "package:flutter/material.dart";

import "../../domain/models/plank_result.dart";

class PlankResultScreen extends StatelessWidget {
  const PlankResultScreen({super.key, required this.result});

  final PlankResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("結果")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.celebration, size: 64),
            const SizedBox(height: 16),
            Text(
              result.plankTypeName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "+${result.earnedExp} EXP",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text("基本EXP: ${result.baseExp}"),
            Text("ストリーク: ${result.streakAfter}日"),
            if (result.streakIncreased)
              const Text("ストリーク +1！"),
            if (result.levelUp)
              Text("レベルアップ！ Lv ${result.levelAfter}"),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              child: const Text("ホームへ"),
            ),
          ],
        ),
      ),
    );
  }
}
