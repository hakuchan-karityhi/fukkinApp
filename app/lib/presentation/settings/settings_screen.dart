import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../records/widgets/milestone_debug_panel.dart";
import "../records/widgets/streak_debug_panel.dart";
import "../../app/providers.dart";

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text("設定"),
            subtitle: Text("各種設定は今後追加予定です。"),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const _DebugSection(),
          ],
        ],
      ),
    );
  }
}

class _DebugSection extends ConsumerStatefulWidget {
  const _DebugSection();

  @override
  ConsumerState<_DebugSection> createState() => _DebugSectionState();
}

class _DebugSectionState extends ConsumerState<_DebugSection> {
  bool _isResetting = false;

  Future<void> _confirmAndReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("進捗を全てリセット"),
        content: const Text(
          "EXP・レベル・ストリーク・実施履歴・マイルストーン達成を初期状態に戻します。\nこの操作は取り消せません。",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("キャンセル"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("リセット"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isResetting = true);
    try {
      await ref.read(resetProgressUseCaseProvider).execute();
      ref.invalidate(userProgressProvider);
      ref.invalidate(streakStateProvider);
      ref.invalidate(milestoneTargetsProvider);
      ref.invalidate(milestoneAchievementsProvider);
      ref.invalidate(todayWorkoutSummaryProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("進捗をリセットしました")),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("リセットに失敗しました: $error")),
      );
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(milestoneTargetsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "デバッグ",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "開発ビルドのみ表示されます。",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isResetting ? null : _confirmAndReset,
          icon: _isResetting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restart_alt),
          label: Text(_isResetting ? "リセット中…" : "進捗を全てリセット"),
        ),
        const SizedBox(height: 16),
        const StreakDebugPanel(),
        const SizedBox(height: 16),
        targetsAsync.when(
          data: (targets) => MilestoneDebugPanel(targets: targets),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
