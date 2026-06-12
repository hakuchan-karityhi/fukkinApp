import "package:flutter/material.dart";

import "../../../domain/models/plank_type.dart";
import "../../widgets/plank_pose_view.dart";
import "../../widgets/target_seconds_stepper.dart";

class PlankSetDetailPanel extends StatelessWidget {
  const PlankSetDetailPanel({
    super.key,
    required this.setName,
    required this.plankTypes,
    required this.targetSecondsByPlankId,
    required this.onTargetSecondsChanged,
    this.onEdit,
  });

  final String setName;
  final List<PlankType> plankTypes;
  final Map<String, int> targetSecondsByPlankId;
  final void Function(String plankId, int seconds) onTargetSecondsChanged;
  final VoidCallback? onEdit;

  PlankType? get _basicPlank {
    for (final plank in plankTypes) {
      if (plank.id == "PK-01") return plank;
    }
    return plankTypes.isEmpty ? null : plankTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    final basicPlank = _basicPlank;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 108),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (basicPlank != null)
            PlankPoseView(
              plankType: basicPlank,
              size: 180,
              showLabel: false,
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  setName,
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
                  tooltip: "セットを編集",
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final plank in plankTypes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      plank.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TargetSecondsStepper(
                    compact: true,
                    seconds: targetSecondsByPlankId[plank.id] ??
                        plank.defaultSeconds,
                    onChanged: (seconds) =>
                        onTargetSecondsChanged(plank.id, seconds),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
