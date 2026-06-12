class CustomPlankType {
  const CustomPlankType({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  static const idPrefix = "CUST-";
  static const maxCount = 20;
  static const maxNameLength = 30;

  bool get isValidId => id.startsWith(idPrefix);
}
