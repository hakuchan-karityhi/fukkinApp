import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/milestone.dart";
import "../../domain/models/plank_result.dart";
import "../../domain/models/plank_set.dart";
import "../../domain/models/plank_type.dart";
import "../plank_session/plank_exercise_timer.dart";
import "../widgets/plank_pose_view.dart";
import "plank_set_result_screen.dart";

class PlankSetSessionScreen extends ConsumerStatefulWidget {
  const PlankSetSessionScreen({
    super.key,
    required this.plankSet,
    required this.plankTypes,
    required this.targetSeconds,
  });

  final PlankSetDefinition plankSet;
  final List<PlankType> plankTypes;
  final int targetSeconds;

  @override
  ConsumerState<PlankSetSessionScreen> createState() =>
      _PlankSetSessionScreenState();
}

class _PlankSetSessionScreenState extends ConsumerState<PlankSetSessionScreen> {
  var _currentIndex = 0;
  var _awaitingAction = false;
  final _completedResults = <PlankResult>[];

  int get _totalCount => widget.plankTypes.length;
  bool get _isLastPlank => _currentIndex >= _totalCount - 1;
  PlankType get _currentPlank => widget.plankTypes[_currentIndex];

  Future<bool> _confirmAbortSet() async {
    final hasCompleted = _completedResults.isNotEmpty;
    final message = hasCompleted
        ? "セットを中断してホームに戻ります。完了した種目は記録済みです。"
        : "セットを中断してホームに戻ります。";

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("セットを中断しますか？"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("続ける"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("ホームへ"),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  Future<void> _exitToHome() async {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onPlankCompleted() async {
    final useCase = ref.read(completePlankUseCaseProvider);
    if (useCase == null) {
      throw StateError("CompletePlankUseCase is not ready");
    }

    final result = await useCase.execute(
      plankTypeId: _currentPlank.id,
      targetSeconds: widget.targetSeconds,
    );
    _completedResults.add(result);

    if (!mounted) return;
    setState(() => _awaitingAction = true);
  }

  MilestoneAchievement? _firstMilestone(List<PlankResult> results) {
    for (final item in results) {
      if (item.milestoneReached != null) {
        return item.milestoneReached;
      }
    }
    return null;
  }

  Future<void> _goToResultScreen() async {
    if (_completedResults.isEmpty || !mounted) return;

    final lastResult = _completedResults.last;
    final setResult = PlankSetResult(
      setId: widget.plankSet.id,
      setName: widget.plankSet.name,
      targetSeconds: widget.targetSeconds,
      plankResults: List.unmodifiable(_completedResults),
      totalEarnedExp:
          _completedResults.fold(0, (sum, item) => sum + item.earnedExp),
      totalExpAfter: lastResult.totalExpAfter,
      levelAfter: lastResult.levelAfter,
      levelUp: _completedResults.any((item) => item.levelUp),
      streakAfter: lastResult.streakAfter,
      streakIncreased:
          _completedResults.any((item) => item.streakIncreased),
      milestoneReached: _firstMilestone(_completedResults),
    );

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PlankSetResultScreen(result: setResult),
      ),
    );
  }

  void _goToNextPlank() {
    setState(() {
      _currentIndex++;
      _awaitingAction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lastResult =
        _completedResults.isEmpty ? null : _completedResults.last;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmAbortSet()) {
          await _exitToHome();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentPlank.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _awaitingAction && lastResult != null
                ? _PlankCompletedPanel(
                    plankType: _currentPlank,
                    progressLabel: "${_currentIndex + 1}/$_totalCount",
                    earnedExp: lastResult.earnedExp,
                    showNextButton: !_isLastPlank,
                    onNext: _goToNextPlank,
                    onFinish: _goToResultScreen,
                  )
                : PlankExerciseTimer(
                    key: ValueKey(_currentIndex),
                    plankType: _currentPlank,
                    targetSeconds: widget.targetSeconds,
                    progressLabel: "${_currentIndex + 1}/$_totalCount",
                    onExitConfirmed: () async {
                      if (await _confirmAbortSet()) {
                        await _exitToHome();
                      }
                    },
                    onTimerComplete: _onPlankCompleted,
                  ),
          ),
        ),
      ),
    );
  }
}

class _PlankCompletedPanel extends StatelessWidget {
  const _PlankCompletedPanel({
    required this.plankType,
    required this.progressLabel,
    required this.earnedExp,
    required this.showNextButton,
    required this.onNext,
    required this.onFinish,
  });

  final PlankType plankType;
  final String progressLabel;
  final int earnedExp;
  final bool showNextButton;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            progressLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          PlankPoseView(
            plankType: plankType,
            size: 200,
            showLabel: false,
          ),
          const SizedBox(height: 16),
          Text(
            "完了",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "+$earnedExp EXP",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (showNextButton) ...[
            FilledButton(
              onPressed: onNext,
              child: const Text("次の種目へ"),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton(
            onPressed: onFinish,
            child: const Text("終了"),
          ),
        ],
      ),
    );
  }
}
