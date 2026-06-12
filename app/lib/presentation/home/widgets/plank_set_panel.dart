import "package:flutter/material.dart";

import "../../../domain/models/plank_type.dart";
import "../../widgets/plank_pose_view.dart";

class PlankSetDetailPanel extends StatelessWidget {
  const PlankSetDetailPanel({
    super.key,
    required this.setName,
    required this.plankTypes,
    required this.targetSeconds,
  });

  final String setName;
  final List<PlankType> plankTypes;
  final int targetSeconds;

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
          Text(
            setName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          for (final plank in plankTypes)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "${plank.name}$targetSeconds秒",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
