import "package:flutter/material.dart";

class ExpGainProgressBar extends StatefulWidget {
  const ExpGainProgressBar({
    super.key,
    required this.totalExpBefore,
    required this.totalExpAfter,
    required this.earnedExp,
    required this.levelThresholds,
    this.autoStart = true,
    this.startDelay = Duration.zero,
  });

  final int totalExpBefore;
  final int totalExpAfter;
  final int earnedExp;
  final List<int> levelThresholds;
  final bool autoStart;
  final Duration startDelay;

  @override
  State<ExpGainProgressBar> createState() => _ExpGainProgressBarState();
}

class _ExpGainProgressBarState extends State<ExpGainProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expAnimation;

  int _displayTotalExp = 0;
  int _displayEarnedExp = 0;

  @override
  void initState() {
    super.initState();
    _displayTotalExp = widget.totalExpBefore;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _expAnimation = Tween<double>(
      begin: widget.totalExpBefore.toDouble(),
      end: widget.totalExpAfter.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.addListener(_onTick);

    if (widget.autoStart) {
      Future<void>.delayed(widget.startDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  void _onTick() {
    final animatedExp = _expAnimation.value.round();
    final earned = ((animatedExp - widget.totalExpBefore).clamp(
      0,
      widget.earnedExp,
    )).toInt();

    setState(() {
      _displayTotalExp = animatedExp;
      _displayEarnedExp = earned;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thresholds = widget.levelThresholds;
    final level = _levelFor(_displayTotalExp, thresholds);
    final previousThreshold = _previousThreshold(_displayTotalExp, thresholds);
    final nextThreshold = _nextThreshold(_displayTotalExp, thresholds);
    final span = nextThreshold - previousThreshold;
    final currentInLevel = _displayTotalExp - previousThreshold;
    final ratio = span == 0 ? 0.0 : (currentInLevel / span).clamp(0.0, 1.0);

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lv $level",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "$currentInLevel / $span",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: ratio),
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                builder: (context, animatedRatio, child) {
                  return Stack(
                    children: [
                      LinearProgressIndicator(
                        value: animatedRatio,
                        minHeight: 14,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                      ),
                      if (_displayEarnedExp > 0 && animatedRatio > 0.02)
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "+$_displayEarnedExp EXP",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _levelFor(int totalExp, List<int> thresholds) {
    var level = 1;
    for (final threshold in thresholds) {
      if (totalExp >= threshold) {
        level++;
      }
    }
    return level;
  }

  int _nextThreshold(int totalExp, List<int> thresholds) {
    for (final threshold in thresholds) {
      if (totalExp < threshold) return threshold;
    }
    return thresholds.last + 100;
  }

  int _previousThreshold(int totalExp, List<int> thresholds) {
    var previous = 0;
    for (final threshold in thresholds) {
      if (totalExp < threshold) return previous;
      previous = threshold;
    }
    return previous;
  }
}
