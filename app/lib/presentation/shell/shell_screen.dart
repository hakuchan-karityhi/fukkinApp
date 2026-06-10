import "package:flutter/material.dart";

/// 起動確認用プレースホルダ。ホーム統合 UI は MVP / BETA-002 以降で実装。
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ふっきん")),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64),
            SizedBox(height: 16),
            Text("Plank Buddy", style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text("開発基盤 Ready"),
          ],
        ),
      ),
    );
  }
}
