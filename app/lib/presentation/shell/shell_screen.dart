import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";

/// 起動確認用プレースホルダ。ホーム統合 UI は MVP / BETA-002 以降で実装。
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(gameConstantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("ふっきん")),
      body: Center(
        child: constants.when(
          data: (c) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 64),
              const SizedBox(height: 16),
              const Text("Plank Buddy", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text("日次EXP上限: ${c.dailyExpCap}"),
              Text("レベル閾値: ${c.levelThresholds.join(", ")}"),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text("Error: $e"),
        ),
      ),
    );
  }
}
