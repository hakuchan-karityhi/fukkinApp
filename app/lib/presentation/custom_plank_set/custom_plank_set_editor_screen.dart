import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/custom_plank_set.dart";
import "../../domain/models/plank_type.dart";
import "../../infrastructure/master/custom_plank_set_ids.dart";
import "../widgets/target_seconds_stepper.dart";

class CustomPlankSetEditorScreen extends ConsumerStatefulWidget {
  const CustomPlankSetEditorScreen({
    super.key,
    this.existingSetId,
  });

  final String? existingSetId;

  @override
  ConsumerState<CustomPlankSetEditorScreen> createState() =>
      _CustomPlankSetEditorScreenState();
}

class _CustomPlankSetEditorScreenState
    extends ConsumerState<CustomPlankSetEditorScreen> {
  final _nameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _existingId;
  List<CustomPlankSetItem> _items = [];

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
    if (widget.existingSetId != null) {
      final existing = await ref
          .read(customPlankSetRepositoryProvider)
          .getById(widget.existingSetId!);
      if (existing != null) {
        _nameController.text = existing.name;
        _existingId = existing.id;
        _items = List.of(existing.items);
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _showAlert(String message) {
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

  String? _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return "セット名を入力してください";
    if (name.length > CustomPlankSet.maxNameLength) {
      return "セット名は${CustomPlankSet.maxNameLength}文字以内にしてください";
    }
    if (_items.length < CustomPlankSet.minItems) {
      return "種目は${CustomPlankSet.minItems}種目以上追加してください";
    }
    if (_items.length > CustomPlankSet.maxItems) {
      return "種目は${CustomPlankSet.maxItems}種目までです";
    }
    final ids = _items.map((item) => item.plankTypeId).toList();
    if (ids.length != ids.toSet().length) {
      return "同じ種目を重複して追加できません";
    }
    return null;
  }

  Future<void> _addPlank() async {
    if (_items.length >= CustomPlankSet.maxItems) {
      await _showAlert("種目は${CustomPlankSet.maxItems}種目までです");
      return;
    }

    final planks = await ref.read(plankTypesProvider.future);
    final usedIds = _items.map((item) => item.plankTypeId).toSet();
    final available = planks.where((p) => !usedIds.contains(p.id)).toList();

    if (available.isEmpty) {
      await _showAlert("追加できる種目がありません");
      return;
    }

    if (!mounted) return;
    final picked = await showModalBottomSheet<PlankType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "種目を追加",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final plank in available)
              ListTile(
                title: Text(plank.name),
                onTap: () => Navigator.of(context).pop(plank),
              ),
          ],
        ),
      ),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _items = [
        ..._items,
        CustomPlankSetItem(
          plankTypeId: picked.id,
          targetSeconds: picked.defaultSeconds,
        ),
      ];
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items = [..._items]..removeAt(index);
    });
  }

  void _moveItem(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _items.length) return;
    setState(() {
      final next = [..._items];
      final item = next.removeAt(index);
      next.insert(newIndex, item);
      _items = next;
    });
  }

  void _updateSeconds(int index, int seconds) {
    setState(() {
      final item = _items[index];
      _items = [
        ..._items.sublist(0, index),
        CustomPlankSetItem(
          plankTypeId: item.plankTypeId,
          targetSeconds: TargetSeconds.clamp(seconds),
        ),
        ..._items.sublist(index + 1),
      ];
    });
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      await _showAlert(error);
      return;
    }

    setState(() => _saving = true);

    try {
      final set = CustomPlankSet(
        id: _existingId ?? generateCustomPlankSetId(),
        name: _nameController.text.trim(),
        items: _items,
        updatedAt: DateTime.now(),
      );

      await ref.read(customPlankSetRepositoryProvider).save(set);
      ref.invalidate(customPlankSetsProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("保存に失敗しました。アプリを再起動してお試しください")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final id = _existingId;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("セットを削除"),
        content: Text("「${_nameController.text.trim()}」を削除しますか？"),
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
    await ref.read(customPlankSetRepositoryProvider).delete(id);
    ref.invalidate(customPlankSetsProvider);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final plankTypesAsync = ref.watch(plankTypesProvider);
    final plankNames = plankTypesAsync.valueOrNull == null
        ? const <String, String>{}
        : {for (final p in plankTypesAsync.valueOrNull!) p.id: p.name};

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingId == null ? "セットを作る" : "セットを編集"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "セット名",
                          hintText: "例: 朝のルーティン",
                          border: OutlineInputBorder(),
                        ),
                        maxLength: CustomPlankSet.maxNameLength,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "種目（${_items.length}/${CustomPlankSet.maxItems}）",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        Text(
                          "＋ 種目を追加してください",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      for (var i = 0; i < _items.length; i++) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plankNames[_items[i].plankTypeId] ??
                                            _items[i].plankTypeId,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: i > 0
                                          ? () => _moveItem(i, -1)
                                          : null,
                                      icon: const Icon(Icons.arrow_upward),
                                      tooltip: "上へ",
                                    ),
                                    IconButton(
                                      onPressed: i < _items.length - 1
                                          ? () => _moveItem(i, 1)
                                          : null,
                                      icon: const Icon(Icons.arrow_downward),
                                      tooltip: "下へ",
                                    ),
                                    IconButton(
                                      onPressed: () => _removeItem(i),
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: "削除",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: TargetSecondsStepper(
                                    compact: true,
                                    seconds: _items[i].targetSeconds,
                                    onChanged: (seconds) =>
                                        _updateSeconds(i, seconds),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _addPlank,
                        icon: const Icon(Icons.add),
                        label: const Text("種目を追加"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("保存"),
                        ),
                      ),
                      if (_existingId != null) ...[
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
                ),
              ],
            ),
    );
  }
}
