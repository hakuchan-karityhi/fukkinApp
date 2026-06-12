import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/character_dialogues.dart";
import "../widgets/character_expression_view.dart";

const _stageCount = 5;

const _stageLabels = [
  "ふつうのお腹",
  "うっすら線",
  "薄く割れ始め",
  "はっきり六塊",
  "最大進化",
];

class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  final _pageController = PageController();
  int _selectedStage = 0;
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStage(int stage) {
    _pageController.animateToPage(
      stage,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _showEnlargedPreview({
    required int stage,
    required bool unlocked,
    required CharacterExpression expression,
  }) {
    if (!unlocked) return;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ステージ $stage",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _stageLabels[stage],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CharacterExpressionView(
                absStage: stage,
                expression: expression,
                size: 180,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("閉じる"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userProgressProvider);
    final constantsAsync = ref.watch(gameConstantsProvider);
    final dialoguesAsync = ref.watch(characterDialoguesProvider);

    return Scaffold(
      appBar: AppBar(
        title: progressAsync.when(
          data: (progress) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("アルバム"),
              Text(
                "現在: ステージ ${progress.absStage}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          loading: () => const Text("アルバム"),
          error: (_, __) => const Text("アルバム"),
        ),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("読み込みに失敗: $error")),
        data: (progress) => constantsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text("定数の読み込みに失敗: $error")),
          data: (constants) => dialoguesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text("キャラデータの読み込みに失敗: $error")),
            data: (master) {
              final thresholds = constants.levelThresholds;
              final currentStage = progress.absStage.clamp(0, 4);

              if (!_initialScrollDone) {
                _initialScrollDone = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _pageController.hasClients) {
                    _pageController.jumpToPage(currentStage);
                    setState(() => _selectedStage = currentStage);
                  }
                });
              }

              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _stageCount,
                      onPageChanged: (index) =>
                          setState(() => _selectedStage = index),
                      itemBuilder: (context, stage) {
                        final unlocked = stage <= currentStage;
                        final expression = master.expressions[stage.toString()] ??
                            master.expressions["0"]!;
                        final requiredExp = _requiredExpForStage(stage, thresholds);

                        return _StagePreviewCard(
                          stage: stage,
                          label: _stageLabels[stage],
                          unlocked: unlocked,
                          isCurrent: stage == currentStage,
                          requiredExp: requiredExp,
                          expression: expression,
                          onTap: () => _showEnlargedPreview(
                            stage: stage,
                            unlocked: unlocked,
                            expression: expression,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StageThumbnailRow(
                    currentStage: currentStage,
                    selectedStage: _selectedStage,
                    thresholds: thresholds,
                    onStageTap: _goToStage,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

int _requiredExpForStage(int stage, List<int> thresholds) {
  return switch (stage) {
    0 => 0,
    1 => thresholds[0],
    2 => thresholds[1],
    3 => thresholds[2],
    4 => thresholds[3],
    _ => 0,
  };
}

class _StagePreviewCard extends StatelessWidget {
  const _StagePreviewCard({
    required this.stage,
    required this.label,
    required this.unlocked,
    required this.isCurrent,
    required this.requiredExp,
    required this.expression,
    required this.onTap,
  });

  final int stage;
  final String label;
  final bool unlocked;
  final bool isCurrent;
  final int requiredExp;
  final CharacterExpression expression;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Card(
        elevation: isCurrent ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: isCurrent ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "現在のステージ",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                if (isCurrent) const SizedBox(height: 12),
                Text(
                  "ステージ $stage",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                if (unlocked)
                  CharacterExpressionView(
                    absStage: stage,
                    expression: expression,
                    size: 160,
                  )
                else
                  _LockedStagePreview(requiredExp: requiredExp),
                const SizedBox(height: 16),
                Text(
                  unlocked
                      ? "到達済み"
                      : "必要累計 EXP: $requiredExp",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: unlocked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (unlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    "タップで拡大",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedStagePreview extends StatelessWidget {
  const _LockedStagePreview({required this.requiredExp});

  final int requiredExp;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "未到達",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _StageThumbnailRow extends StatelessWidget {
  const _StageThumbnailRow({
    required this.currentStage,
    required this.selectedStage,
    required this.thresholds,
    required this.onStageTap,
  });

  final int currentStage;
  final int selectedStage;
  final List<int> thresholds;
  final ValueChanged<int> onStageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var stage = 0; stage < _stageCount; stage++)
            _StageThumbnail(
              stage: stage,
              unlocked: stage <= currentStage,
              isSelected: stage == selectedStage,
              isCurrent: stage == currentStage,
              onTap: () => onStageTap(stage),
            ),
        ],
      ),
    );
  }
}

class _StageThumbnail extends StatelessWidget {
  const _StageThumbnail({
    required this.stage,
    required this.unlocked,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  final int stage;
  final bool unlocked;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isCurrent
                ? colorScheme.primary
                : isSelected
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
            width: isCurrent ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: unlocked
              ? Text(
                  "$stage",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                )
              : Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
