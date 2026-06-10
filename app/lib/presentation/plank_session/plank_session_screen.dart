import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../result/plank_result_screen.dart";
import "../widgets/plank_pose_view.dart";

class PlankSessionScreen extends ConsumerStatefulWidget {
  const PlankSessionScreen({
    super.key,
    required this.plankType,
    required this.targetSeconds,
  });

  final PlankType plankType;
  final int targetSeconds;

  @override
  ConsumerState<PlankSessionScreen> createState() => _PlankSessionScreenState();
}

class _PlankSessionScreenState extends ConsumerState<PlankSessionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.targetSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Future<void> _complete() async {
    if (_isCompleting) return;

    final useCase = ref.read(completePlankUseCaseProvider);
    if (useCase == null) return;

    setState(() => _isCompleting = true);
    _timer?.cancel();

    try {
      final result = await useCase.execute(
        plankTypeId: widget.plankType.id,
        targetSeconds: widget.targetSeconds,
      );

      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlankResultScreen(result: result),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("完了処理に失敗しました: $error")),
      );
      setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plankType.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlankPoseView(
              plankType: widget.plankType,
              size: 80,
              showLabel: false,
            ),
            const SizedBox(height: 16),
            Text(
              "$_remainingSeconds",
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const Text("秒"),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isCompleting ? null : _toggleTimer,
                  child: Text(_isRunning ? "一時停止" : "開始"),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isCompleting ? null : _complete,
                  child: _isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("完了"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
