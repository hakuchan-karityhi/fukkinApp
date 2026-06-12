import "plank_set.dart";

class CustomPlankSetItem {
  const CustomPlankSetItem({
    required this.plankTypeId,
    required this.targetSeconds,
  });

  final String plankTypeId;
  final int targetSeconds;
}

class CustomPlankSet {
  const CustomPlankSet({
    required this.id,
    required this.name,
    required this.items,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<CustomPlankSetItem> items;
  final DateTime updatedAt;

  static const idPrefix = "CSET-";
  static const maxNameLength = 30;
  static const minItems = 2;
  static const maxItems = 9;

  PlankSetDefinition toDefinition() {
    return PlankSetDefinition(
      id: id,
      name: name,
      plankTypeIds: [for (final item in items) item.plankTypeId],
    );
  }
}
