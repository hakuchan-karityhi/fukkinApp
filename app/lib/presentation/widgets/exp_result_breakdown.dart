import "package:flutter/material.dart";

import "../../domain/models/plank_result.dart";

class ExpResultBreakdown extends StatelessWidget {
  const ExpResultBreakdown({
    super.key,
    required this.result,
    this.showDivider = false,
  });

  final PlankResult result;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final mutedStyle = textStyle?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final lines = _buildLines();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 12),
        ],
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    line.label,
                    style: line.isBase ? textStyle : mutedStyle,
                  ),
                ),
                Text(
                  line.value,
                  style: line.isBase
                      ? textStyle?.copyWith(fontWeight: FontWeight.bold)
                      : mutedStyle,
                ),
              ],
            ),
          ),
        if (result.dailyCapReached)
          Text(
            "本日の獲得上限に達したため EXP が調整されました",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }

  List<_BreakdownLine> _buildLines() {
    final lines = <_BreakdownLine>[
      _BreakdownLine(
        label: result.plankTypeName,
        value: "${result.baseExp} EXP",
        isBase: true,
      ),
    ];

    if (result.difficultyMultiplier != 1.0) {
      lines.add(
        _BreakdownLine(
          label: "難易度ボーナス",
          value: "×${_formatMultiplier(result.difficultyMultiplier)}",
        ),
      );
    }

    if (result.streakMultiplier != 1.0) {
      lines.add(
        _BreakdownLine(
          label: "継続ボーナス",
          value: "×${_formatMultiplier(result.streakMultiplier)}",
        ),
      );
    }

    if (result.repeatSessionBonusPercent > 0) {
      final repeatMultiplier =
          1 + result.repeatSessionBonusPercent / 100;
      lines.add(
        _BreakdownLine(
          label: "再実施ボーナス",
          value: "×${_formatMultiplier(repeatMultiplier)}",
        ),
      );
    }

    return lines;
  }

  String _formatMultiplier(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _BreakdownLine {
  const _BreakdownLine({
    required this.label,
    required this.value,
    this.isBase = false,
  });

  final String label;
  final String value;
  final bool isBase;
}
