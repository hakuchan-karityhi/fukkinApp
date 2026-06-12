import "../models/custom_plank_type.dart";
import "../models/plank_type.dart";

/// PK-01 ベーシックプランク相当のゲーム数値・ポーズでカスタム種目を表現する。
class CustomPlankTypeMapper {
  const CustomPlankTypeMapper._();

  static const basicPlankTemplateId = "PK-01";

  static bool isCustomPlankTypeId(String id) =>
      id.startsWith(CustomPlankType.idPrefix);

  static PlankType toPlankType({
    required CustomPlankType custom,
    required PlankType basicTemplate,
  }) {
    return PlankType(
      id: custom.id,
      name: custom.name,
      difficulty: basicTemplate.difficulty,
      expMultiplier: basicTemplate.expMultiplier,
      defaultSeconds: basicTemplate.defaultSeconds,
      enabledInMvp: true,
      enabledInBeta: true,
      poseAssetId: basicTemplate.poseAssetId,
      formImageAsset: basicTemplate.formImageAsset,
      recommendedSecondsMin: basicTemplate.recommendedSecondsMin,
      recommendedSecondsMax: basicTemplate.recommendedSecondsMax,
      isPerSide: false,
    );
  }
}
