import "../../domain/models/custom_plank_set.dart";

String generateCustomPlankSetId() {
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return "${CustomPlankSet.idPrefix}$ts";
}
