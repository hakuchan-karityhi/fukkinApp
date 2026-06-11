import "package:flutter/material.dart";

import "../../domain/models/plank_result.dart";
import "../widgets/milestone_celebration.dart";

class PlankResultScreen extends StatelessWidget {
  const PlankResultScreen({super.key, required this.result});

  final PlankResult result;

  @override
  Widget build(BuildContext context) {
    final milestone = result.milestoneReached;

    return Scaffold(
      appBar: AppBar(title: const Text("結果")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.streakIncreased) ...[
              const Icon(Icons.local_fire_department, size: 64),
              Text(
                "ストリーク ${result.streakAfter}日！",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (milestone != null) ...[
              MilestoneCelebration(milestone: milestone),
              const SizedBox(height: 16),
            ],
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
            if (result.levelUp)
              Text("レベルアップ！ Lv ${result.levelAfter}"),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("ホームへ"),
            ),
          ],
        ),
      ),
    );
  }
}
