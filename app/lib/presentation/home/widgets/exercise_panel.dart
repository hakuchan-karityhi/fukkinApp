import "package:flutter/material.dart";

import "../../../domain/models/plank_type.dart";
import "../../widgets/plank_pose_view.dart";
import "../../widgets/target_seconds_stepper.dart";

class PlankDetailPanel extends StatelessWidget {
  const PlankDetailPanel({
    super.key,
    required this.plank,
    required this.targetSeconds,
    required this.onTargetSecondsChanged,
    this.onEdit,
  });

  final PlankType plank;
  final int targetSeconds;
  final ValueChanged<int> onTargetSecondsChanged;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 108),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlankPoseView(plankType: plank, size: 180, showLabel: false),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  plank.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: "種目を編集",
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TargetSecondsStepper(
            seconds: targetSeconds,
            onChanged: onTargetSecondsChanged,
          ),
          const SizedBox(height: 4),
          Center(child: _DifficultyStars(difficulty: plank.difficulty)),
          if (plank.isPerSide) ...[
            const SizedBox(height: 4),
            Text(
              "1側あたりの秒数（基本EXP）",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class HomeNavArrowButton extends StatelessWidget {
  const HomeNavArrowButton({super.key, required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon),
      ),
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < difficulty;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 18,
          color: filled ? Colors.orange : Colors.grey,
        );
      }),
    );
  }
}

class VerticalScrollHint extends StatefulWidget {
  const VerticalScrollHint({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  final int currentIndex;
  final int pageCount;

  @override
  State<VerticalScrollHint> createState() => _VerticalScrollHintState();
}

class _VerticalScrollHintState extends State<VerticalScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _canScrollUp => widget.currentIndex > 0;
  bool get _canScrollDown => widget.currentIndex < widget.pageCount - 1;

  @override
  Widget build(BuildContext context) {
    if (widget.pageCount <= 1) {
      return const SizedBox.shrink();
    }

    final background = Theme.of(context).scaffoldBackgroundColor;
    final hintColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return IgnorePointer(
      child: Stack(
        children: [
          if (_canScrollUp)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      background.withValues(alpha: 0.92),
                      background.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 30,
                      color: hintColor.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ),
          if (_canScrollDown)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 88,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      background.withValues(alpha: 0.94),
                      background.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _pulse,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 34,
                        color: hintColor.withValues(alpha: 0.9),
                      ),
                    ),
                    if (widget.currentIndex == 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        "上下にスワイプ",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: hintColor.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
