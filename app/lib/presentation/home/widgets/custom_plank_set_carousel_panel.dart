import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/providers.dart";
import "../../../domain/models/custom_plank_set.dart";
import "../../../domain/models/plank_type.dart";
import "../../widgets/target_seconds_stepper.dart";
import "plank_set_panel.dart";

class CustomPlankSetCarouselPanel extends ConsumerWidget {
  const CustomPlankSetCarouselPanel({
    super.key,
    required this.set,
    required this.onEdit,
    required this.onTargetSecondsChanged,
  });

  final CustomPlankSet set;
  final VoidCallback onEdit;
  final void Function(String plankId, int seconds) onTargetSecondsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plankTypesAsync = ref.watch(plankTypesProvider);
    final overrides =
        ref.watch(customPlankSetTargetSecondsProvider)[set.id] ?? const {};

    return plankTypesAsync.when(
      data: (allTypes) {
        final types = _resolvePlankTypes(allTypes, set);
        final seconds = {
          for (final item in set.items)
            item.plankTypeId: TargetSeconds.clamp(
              overrides[item.plankTypeId] ?? item.targetSeconds,
            ),
        };

        return PlankSetDetailPanel(
          setName: set.name,
          plankTypes: types,
          targetSecondsByPlankId: seconds,
          onTargetSecondsChanged: onTargetSecondsChanged,
          onEdit: onEdit,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }

  static List<PlankType> _resolvePlankTypes(
    List<PlankType> allTypes,
    CustomPlankSet set,
  ) {
    final byId = {for (final plank in allTypes) plank.id: plank};
    final types = <PlankType>[];
    for (final item in set.items) {
      final plank = byId[item.plankTypeId];
      if (plank != null) {
        types.add(plank);
      }
    }
    return types;
  }

  static List<int> targetSecondsList(
    CustomPlankSet set,
    Map<String, int> secondsByPlankId,
  ) {
    return [
      for (final item in set.items)
        TargetSeconds.clamp(
          secondsByPlankId[item.plankTypeId] ?? item.targetSeconds,
        ),
    ];
  }

  static List<PlankType> resolvePlankTypes(
    List<PlankType> allTypes,
    CustomPlankSet set,
  ) =>
      _resolvePlankTypes(allTypes, set);
}
