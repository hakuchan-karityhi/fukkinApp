import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../domain/models/milestone.dart";

class MilestoneTargetEditor extends StatelessWidget {
  const MilestoneTargetEditor({
    super.key,
    required this.targets,
    required this.achievements,
    required this.currentStreak,
    required this.onAdd,
    required this.onRemove,
  });

  final List<MilestoneTarget> targets;
  final List<MilestoneAchievement> achievements;
  final int currentStreak;
  final Future<void> Function(MilestoneTarget target) onAdd;
  final Future<void> Function(MilestoneTarget target) onRemove;

  @override
  Widget build(BuildContext context) {
    final achievedDays = achievements.map((item) => item.days).toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "マイルストーン目標",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text("目標を追加"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "達成したい日数と称号を自分で設定できます。",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final target in targets) ...[
              _TargetRow(
                target: target,
                achieved: achievedDays.contains(target.days),
                remainingDays: target.days - currentStreak,
                onRemove: target.isBuiltin ? null : () => onRemove(target),
              ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final daysController = TextEditingController();
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("マイルストーンを追加"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: daysController,
                  decoration: const InputDecoration(
                    labelText: "目標日数",
                    suffixText: "日",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final days = int.tryParse(value ?? "");
                    if (days == null || days < 1) {
                      return "1以上の日数を入力してください";
                    }
                    if (days > 999) {
                      return "999日以下で入力してください";
                    }
                    if (targets.any((target) => target.days == days)) {
                      return "この日数は既に登録されています";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "称号名",
                  ),
                  maxLength: 20,
                  validator: (value) {
                    final title = value?.trim() ?? "";
                    if (title.isEmpty) {
                      return "称号名を入力してください";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("キャンセル"),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text("追加"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final days = int.parse(daysController.text);
      final title = titleController.text.trim();
      await onAdd(MilestoneTarget(days: days, title: title));
    }

    daysController.dispose();
    titleController.dispose();
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.target,
    required this.achieved,
    required this.remainingDays,
    required this.onRemove,
  });

  final MilestoneTarget target;
  final bool achieved;
  final int remainingDays;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusText = achieved
        ? "達成済み"
        : remainingDays <= 0
            ? "あと少し！"
            : "あと$remainingDays日";

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        achieved ? Icons.emoji_events : Icons.flag_outlined,
        color: achieved ? colorScheme.primary : colorScheme.outline,
      ),
      title: Text("${target.days}日 ${target.title}"),
      subtitle: Text(
        target.isBuiltin ? "デフォルト · $statusText" : "カスタム · $statusText",
      ),
      trailing: onRemove == null
          ? null
          : IconButton(
              tooltip: "削除",
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
    );
  }
}
