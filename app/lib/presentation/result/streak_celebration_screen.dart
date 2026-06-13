import "package:flutter/material.dart";

class StreakCelebrationScreen extends StatefulWidget {
  const StreakCelebrationScreen({
    super.key,
    required this.streakAfter,
    required this.streakIncreased,
    required this.nextScreen,
  });

  final int streakAfter;
  final bool streakIncreased;
  final Widget nextScreen;

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen>
    with SingleTickerProviderStateMixin {
  static const _characterImageAsset = "assets/character/kangaru1.png";

  late final AnimationController _controller;
  late final Animation<double> _plusScale;
  late final Animation<double> _countFade;

  @override
  void initState() {
    super.initState();
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
                    const SizedBox(height: 24),
                    Text(
                      "ストリーク更新！",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "今日も完了！",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
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
                  const SizedBox(height: 32),
                  Image.asset(
                    _characterImageAsset,
                    height: 180,
                    fit: BoxFit.contain,
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
}) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => StreakCelebrationScreen(
        streakAfter: streakAfter,
        streakIncreased: streakIncreased,
        nextScreen: nextScreen,
      ),
    ),
  );
}
