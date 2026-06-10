import "package:flutter/material.dart";

import "../../domain/models/plank_type.dart";

/// 種目ごとのプレースホルダポーズ表示（BETA-005）。
/// 本番アセット（Lottie/画像）差し替え前の β 用簡易表現。
class PlankPoseView extends StatelessWidget {
  const PlankPoseView({
    super.key,
    required this.plankType,
    this.size = 96,
    this.showLabel = true,
  });

  final PlankType plankType;
  final double size;
  final bool showLabel;

  static const _poseStyles = <String, _PoseStyle>{
    "basic_plank": _PoseStyle(Icons.self_improvement, Color(0xFF4CAF50)),
    "knee_plank": _PoseStyle(Icons.airline_seat_flat, Color(0xFF8BC34A)),
    "high_plank": _PoseStyle(Icons.trending_up, Color(0xFF2196F3)),
    "reverse_plank": _PoseStyle(Icons.flip, Color(0xFF03A9F4)),
    "side_plank": _PoseStyle(Icons.swap_horiz, Color(0xFF9C27B0)),
    "plank_jack": _PoseStyle(Icons.open_in_full, Color(0xFFFF9800)),
    "spider_plank": _PoseStyle(Icons.bug_report, Color(0xFFFF5722)),
    "leg_lift_plank": _PoseStyle(Icons.vertical_align_top, Color(0xFFE91E63)),
    "shoulder_tap_plank": _PoseStyle(Icons.touch_app, Color(0xFF795548)),
  };

  @override
  Widget build(BuildContext context) {
    final style = _poseStyles[plankType.poseAssetId] ??
        const _PoseStyle(Icons.accessibility_new, Color(0xFF607D8B));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.6,
          height: size,
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: style.color.withValues(alpha: 0.35)),
          ),
          child: Icon(style.icon, size: size * 0.5, color: style.color),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            plankType.poseAssetId,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PoseStyle {
  const _PoseStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}
