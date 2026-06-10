class PlankType {
  const PlankType({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.expMultiplier,
    required this.defaultSeconds,
    required this.enabledInMvp,
    required this.enabledInBeta,
    required this.poseAssetId,
    this.formImageAsset,
    required this.recommendedSecondsMin,
    required this.recommendedSecondsMax,
    this.isPerSide = false,
  });

  final String id;
  final String name;
  final int difficulty;
  final double expMultiplier;
  final int defaultSeconds;
  final bool enabledInMvp;
  final bool enabledInBeta;
  final String poseAssetId;
  final String? formImageAsset;
  final int recommendedSecondsMin;
  final int recommendedSecondsMax;
  final bool isPerSide;

  factory PlankType.fromJson(Map<String, dynamic> json) {
    return PlankType(
      id: json["id"] as String,
      name: json["name"] as String,
      difficulty: json["difficulty"] as int,
      expMultiplier: (json["expMultiplier"] as num).toDouble(),
      defaultSeconds: json["defaultSeconds"] as int,
      enabledInMvp: json["enabledInMvp"] as bool,
      enabledInBeta: json["enabledInBeta"] as bool,
      poseAssetId: json["poseAssetId"] as String,
      formImageAsset: json["formImageAsset"] as String?,
      recommendedSecondsMin: json["recommendedSecondsMin"] as int,
      recommendedSecondsMax: json["recommendedSecondsMax"] as int,
      isPerSide: json["isPerSide"] as bool? ?? false,
    );
  }
}
