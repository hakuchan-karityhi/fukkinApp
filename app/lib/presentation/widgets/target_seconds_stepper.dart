import "package:flutter/material.dart";

class TargetSeconds {
  TargetSeconds._();

  static const minSeconds = 10;
  static const maxSeconds = 120;
  static const stepSeconds = 5;

  static int clamp(int seconds) {
    final stepped = (seconds / stepSeconds).round() * stepSeconds;
    return stepped.clamp(minSeconds, maxSeconds);
  }

  static int? decrement(int seconds) {
    final next = seconds - stepSeconds;
    return next >= minSeconds ? next : null;
  }

  static int? increment(int seconds) {
    final next = seconds + stepSeconds;
    return next <= maxSeconds ? next : null;
  }
}

class TargetSecondsStepper extends StatelessWidget {
  const TargetSecondsStepper({
    super.key,
    required this.seconds,
    required this.onChanged,
    this.compact = false,
  });

  final int seconds;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final canDecrease = TargetSeconds.decrement(seconds) != null;
    final canIncrease = TargetSeconds.increment(seconds) != null;
    final valueStyle = compact
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            );
    final buttonSize = compact ? 36.0 : 44.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          label: "−",
          size: buttonSize,
          enabled: canDecrease,
          onPressed: canDecrease
              ? () => onChanged(TargetSeconds.decrement(seconds)!)
              : null,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
          child: Text("$seconds秒", style: valueStyle),
        ),
        _StepperButton(
          label: "+",
          size: buttonSize,
          enabled: canIncrease,
          onPressed: canIncrease
              ? () => onChanged(TargetSeconds.increment(seconds)!)
              : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.size,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final double size;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
