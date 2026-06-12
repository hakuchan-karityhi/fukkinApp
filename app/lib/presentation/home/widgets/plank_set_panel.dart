import "package:flutter/material.dart";

import "../../../domain/models/plank_type.dart";
import "../../widgets/plank_pose_view.dart";

class PlankSetDetailPanel extends StatelessWidget {
  const PlankSetDetailPanel({
    super.key,
    required this.setName,
    required this.plankTypes,
    required this.targetSeconds,
    required this.onTargetSecondsChanged,
  });

  final String setName;
  final List<PlankType> plankTypes;
  final int targetSeconds;
  final ValueChanged<int> onTargetSecondsChanged;

  static const _minSeconds = 10;
  static const _maxSeconds = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 108),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            setName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "3種連続実行",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _PlankSequencePreview(plankTypes: plankTypes),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "目標秒数（共通）",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    "$targetSeconds秒",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 16,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                ),
                child: Slider(
                  value: targetSeconds.toDouble(),
                  min: _minSeconds.toDouble(),
                  max: _maxSeconds.toDouble(),
                  divisions: _maxSeconds - _minSeconds,
                  label: "$targetSeconds秒",
                  onChanged: (value) =>
                      onTargetSecondsChanged(value.round()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlankSequencePreview extends StatelessWidget {
  const _PlankSequencePreview({required this.plankTypes});

  final List<PlankType> plankTypes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < plankTypes.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward,
                size: 18,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          Column(
            children: [
              PlankPoseView(
                plankType: plankTypes[i],
                size: 72,
                showLabel: false,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: Text(
                  plankTypes[i].name,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
