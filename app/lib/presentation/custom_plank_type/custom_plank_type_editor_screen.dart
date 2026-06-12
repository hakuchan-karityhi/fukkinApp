import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/custom_plank_type.dart";
import "../../domain/models/plank_type.dart";
import "../../domain/services/custom_plank_type_mapper.dart";
import "../../infrastructure/master/composite_plank_type_repository.dart";
import "../widgets/plank_pose_view.dart";

class CustomPlankTypeEditorScreen extends ConsumerStatefulWidget {
  const CustomPlankTypeEditorScreen({
    super.key,
    this.existingId,
  });

  final String? existingId;

  @override
  ConsumerState<CustomPlankTypeEditorScreen> createState() =>
      _CustomPlankTypeEditorScreenState();
}

class _CustomPlankTypeEditorScreenState
    extends ConsumerState<CustomPlankTypeEditorScreen> {
  final _nameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  CustomPlankType? _existing;
  PlankType? _previewPlank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(plankTypeRepositoryProvider);
    final template = await repo.getById(CustomPlankTypeMapper.basicPlankTemplateId);

    CustomPlankType? existing;
    if (widget.existingId != null) {
      existing =
          await ref.read(customPlankTypeRepositoryProvider).getById(widget.existingId!);
      if (existing != null) {
        _nameController.text = existing.name;
      }
    }

    if (!mounted) return;
    setState(() {
      _existing = existing;
      _previewPlank = template;
      _loading = false;
    });
  }

  String? _validateName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return "種目名を入力してください";
    if (name.length > CustomPlankType.maxNameLength) {
      return "種目名は${CustomPlankType.maxNameLength}文字以内にしてください";
    }
    return null;
  }

  Future<void> _showValidationAlert(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await _showValidationAlert("種目名を入力してください");
      return;
    }

    final error = _validateName(_nameController.text);
    if (error != null) {
      await _showValidationAlert(error);
      return;
    }

    setState(() => _saving = true);

    try {
      final customRepo = ref.read(customPlankTypeRepositoryProvider);
      final isNew = _existing == null;

      if (isNew) {
        final count = await customRepo.count();
        if (count >= CustomPlankType.maxCount) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("カスタム種目は最大${CustomPlankType.maxCount}件までです"),
            ),
          );
          return;
        }
      }

      final type = CustomPlankType(
        id: _existing?.id ?? generateCustomPlankTypeId(),
        name: _nameController.text.trim(),
        createdAt: _existing?.createdAt ?? DateTime.now(),
      );

      await customRepo.save(type);
      ref.invalidate(customPlankTypesProvider);
      ref.invalidate(plankTypesProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("保存に失敗しました。アプリを再起動してお試しください")),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final existing = _existing;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("種目を削除"),
        content: Text("「${existing.name}」を削除しますか？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("キャンセル"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("削除"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    await ref.read(customPlankTypeRepositoryProvider).delete(existing.id);
    ref.invalidate(customPlankTypesProvider);
    ref.invalidate(plankTypesProvider);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "種目を編集" : "種目を追加"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_previewPlank != null) ...[
                  Center(
                    child: PlankPoseView(
                      plankType: _previewPlank!,
                      size: 180,
                      showLabel: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "見た目はベーシックプランク固定です",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                ],
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "種目名",
                    hintText: "例: 朝のプランク",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: CustomPlankType.maxNameLength,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("保存"),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _saving ? null : _delete,
                      child: const Text("削除"),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
