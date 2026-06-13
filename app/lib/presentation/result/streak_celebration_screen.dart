import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "widgets/streak_calendar_stamp.dart";

class StreakCelebrationScreen extends ConsumerStatefulWidget {
  const StreakCelebrationScreen({
    super.key,
    required this.streakAfter,
    required this.streakIncreased,
    required this.nextScreen,
    this.completedDate,
  });

  final int streakAfter;
  final bool streakIncreased;
  final Widget nextScreen;
  final DateTime? completedDate;

  @override
  ConsumerState<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState
    extends ConsumerState<StreakCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _plusScale;
  late final Animation<double> _countFade;
  late final DateTime _completedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _completedDate = widget.completedDate ??
        DateTime(now.year, now.month, now.day);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _plusScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
    ]).animate(_controller);
    _countFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    if (widget.streakIncreased) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  int get _displayStreakBefore =>
      widget.streakIncreased && widget.streakAfter > 0
          ? widget.streakAfter - 1
          : widget.streakAfter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final streakIncreased = widget.streakIncreased;
    final month = DateTime(_completedDate.year, _completedDate.month);
    final workoutDatesAsync = ref.watch(monthWorkoutDatesProvider(month));

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.55),
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  if (streakIncreased) ...[
                    ScaleTransition(
                      scale: _plusScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "+1",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "ストリーク更新！",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.check_circle_outline,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "今日も完了！",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  workoutDatesAsync.when(
                    data: (dates) => StreakCalendarStamp(
                      year: month.year,
                      month: month.month,
                      workoutDates: dates,
                      stampDate: _completedDate,
                    ),
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: streakIncreased
                        ? _countFade
                        : const AlwaysStoppedAnimation(1.0),
                    child: Column(
                      children: [
                        Text(
                          "${widget.streakAfter}",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                height: 1,
                              ),
                        ),
                        Text(
                          "日連続",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (streakIncreased && _displayStreakBefore > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            "$_displayStreakBefore → ${widget.streakAfter}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "タップして続ける",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void openStreakCelebrationScreen(
  BuildContext context, {
  required int streakAfter,
  required bool streakIncreased,
  required Widget nextScreen,
  DateTime? completedDate,
}) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => StreakCelebrationScreen(
        streakAfter: streakAfter,
        streakIncreased: streakIncreased,
        nextScreen: nextScreen,
        completedDate: completedDate,
      ),
    ),
  );
}
