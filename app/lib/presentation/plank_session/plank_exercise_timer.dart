import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../../app/action_button_styles.dart";
import "../widgets/dialogue_bubble.dart";
import "../widgets/plank_pose_view.dart";
import "plank_session_phase.dart";

class PlankExerciseTimer extends ConsumerStatefulWidget {
  const PlankExerciseTimer({
    super.key,
    required this.plankType,
    required this.targetSeconds,
    required this.onTimerComplete,
    this.progressLabel,
    this.onExitConfirmed,
  });

  final PlankType plankType;
  final int targetSeconds;
  final String? progressLabel;
  final Future<void> Function() onTimerComplete;
  final VoidCallback? onExitConfirmed;

  @override
  ConsumerState<PlankExerciseTimer> createState() => _PlankExerciseTimerState();
}

class _PlankExerciseTimerState extends ConsumerState<PlankExerciseTimer>
    with WidgetsBindingObserver {
  static const _preparingSeconds = 3;

  PlankSessionPhase _phase = PlankSessionPhase.preparing;
  int _preparingCount = _preparingSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  DateTime? _runningStartedAt;
  int _cheerRotation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = widget.targetSeconds;
    _startPreparingCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase != PlankSessionPhase.running || _runningStartedAt == null) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final elapsed = DateTime.now().difference(_runningStartedAt!).inSeconds;
      final newRemaining = widget.targetSeconds - elapsed;
      if (newRemaining <= 0) {
        setState(() {
          _remainingSeconds = 0;
          _phase = PlankSessionPhase.completing;
        });
        unawaited(_handleTimerComplete());
        return;
      }
      setState(() => _remainingSeconds = newRemaining);
      _startRunningTimer();
    }
  }

  void _startPreparingCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_preparingCount <= 1) {
        _timer?.cancel();
        _beginRunning();
        return;
      }
      setState(() => _preparingCount--);
    });
  }

  void _beginRunning() {
    setState(() {
      _phase = PlankSessionPhase.running;
      _remainingSeconds = widget.targetSeconds;
      _runningStartedAt = DateTime.now();
    });
    _startRunningTimer();
  }

  void _startRunningTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _phase = PlankSessionPhase.completing;
        });
        unawaited(_handleTimerComplete());
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds % 12 == 0) {
          _cheerRotation++;
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _phase = PlankSessionPhase.paused);
  }

  void _resume() {
    setState(() {
      _phase = PlankSessionPhase.running;
      _runningStartedAt = DateTime.now().subtract(
        Duration(seconds: widget.targetSeconds - _remainingSeconds),
      );
    });
    _startRunningTimer();
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("終了しますか？"),
        content: const Text("今回のプランクは記録されません。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("キャンセル"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("終了"),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      widget.onExitConfirmed?.call();
    }
  }

  void _debugComplete() {
    if (!kDebugMode || _phase == PlankSessionPhase.completing) return;

    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _phase = PlankSessionPhase.completing;
    });
    unawaited(_handleTimerComplete());
  }

  Future<void> _handleTimerComplete() async {
    try {
      await widget.onTimerComplete();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("完了処理に失敗しました: $error")),
      );
      setState(() => _phase = PlankSessionPhase.running);
      _startRunningTimer();
    }
  }

  String? _buildCheerText() {
    if (_phase != PlankSessionPhase.running) return null;

    final dialogues = ref.watch(characterDialoguesProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    if (dialogues == null || streak == null) return null;

    return ref.watch(characterDialogueSelectorProvider).sessionCheer(
          master: dialogues,
          currentStreak: streak.currentStreak,
          now: DateTime.now(),
          rotationIndex: _cheerRotation,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cheerText = _buildCheerText();
    final displaySeconds =
        _phase == PlankSessionPhase.preparing ? _preparingCount : _remainingSeconds;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            if (widget.progressLabel != null) ...[
              Text(
                widget.progressLabel!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            PlankPoseView(
              plankType: widget.plankType,
              size: 200,
              showLabel: false,
            ),
            if (cheerText != null) ...[
              const SizedBox(height: 12),
              DialogueBubble(text: cheerText),
            ],
            const SizedBox(height: 16),
            if (_phase == PlankSessionPhase.preparing)
              Text(
                "開始まで",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            Text(
              "$displaySeconds",
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            Text(_phase == PlankSessionPhase.preparing ? "" : "秒"),
            const SizedBox(height: 24),
            _buildActionButtons(),
              ],
            ),
          ),
          if (kDebugMode && _phase != PlankSessionPhase.completing)
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: _debugComplete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("debug"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (_phase) {
      case PlankSessionPhase.preparing:
        return const SizedBox.shrink();
      case PlankSessionPhase.running:
        return actionOutlinedButton(
          width: double.infinity,
          onPressed: _pause,
          child: const Text("一時停止"),
        );
      case PlankSessionPhase.paused:
        return Row(
          children: [
            Expanded(
              child: actionFilledButton(
                onPressed: _resume,
                child: const Text("再開"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: actionOutlinedButton(
                onPressed: _confirmExit,
                child: const Text("終了"),
              ),
            ),
          ],
        );
      case PlankSessionPhase.completing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
    }
  }
}
