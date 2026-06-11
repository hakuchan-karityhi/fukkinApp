import "package:flutter/material.dart";

import "../../domain/models/plank_type.dart";

class PlankPoseView extends StatelessWidget {
  const PlankPoseView({
    super.key,
    required this.plankType,
    this.size = 200,
    this.showLabel = true,
  });

  final PlankType plankType;
  final double size;
  final bool showLabel;

  static const _defaultFormImage = "assets/character/kangaru2.png";

  @override
  Widget build(BuildContext context) {
    final imageAsset = plankType.formImageAsset?.isNotEmpty == true
        ? plankType.formImageAsset!
        : _defaultFormImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 2.0,
          height: size * 1.2,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.contain,
          ),
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
