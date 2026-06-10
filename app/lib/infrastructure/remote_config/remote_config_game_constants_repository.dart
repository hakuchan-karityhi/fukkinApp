import "../../domain/models/game_constants.dart";
import "../../domain/repositories/game_constants_repository.dart";
import "local_game_constants_repository.dart";
import "remote_config_keys.dart";

/// Firebase Remote Config 相当のキーで上書きを試みる。
/// 未設定・取得失敗時は [LocalGameConstantsRepository] にフォールバック。
class RemoteConfigGameConstantsRepository implements GameConstantsRepository {
  RemoteConfigGameConstantsRepository({
    required Future<Map<String, dynamic>> Function() fetchOverrides,
    GameConstantsRepository? fallback,
  })  : _fetchOverrides = fetchOverrides,
        _fallback = fallback ?? LocalGameConstantsRepository();

  final Future<Map<String, dynamic>> Function() _fetchOverrides;
  final GameConstantsRepository _fallback;

  @override
  Future<GameConstants> load() async {
    final base = await _fallback.load();
    try {
      final overrides = await _fetchOverrides();
      return _merge(base, overrides);
    } catch (_) {
      return base;
    }
  }

  GameConstants _merge(GameConstants base, Map<String, dynamic> overrides) {
    return GameConstants(
      streakMultipliers: base.streakMultipliers,
      levelThresholds: _parseIntList(
            overrides[RemoteConfigKeys.levelThresholds],
            base.levelThresholds,
          ) ??
          base.levelThresholds,
      secondSessionExpRate: _parseDouble(
            overrides[RemoteConfigKeys.secondSessionExpRate],
            base.secondSessionExpRate,
          ) ??
          base.secondSessionExpRate,
      dailyExpCap: _parseInt(
            overrides[RemoteConfigKeys.dailyExpCap],
            base.dailyExpCap,
          ) ??
          base.dailyExpCap,
      penaltyMinExp: _parseInt(
            overrides[RemoteConfigKeys.penaltyMinExp],
            base.penaltyMinExp,
          ) ??
          base.penaltyMinExp,
      penaltySecondDayRate: _parseDouble(
            overrides[RemoteConfigKeys.penaltySecondDayRate],
            base.penaltySecondDayRate,
          ) ??
          base.penaltySecondDayRate,
    );
  }

  List<int>? _parseIntList(dynamic value, List<int> fallback) {
    if (value is! List) return null;
    final parsed = value.whereType<num>().map((e) => e.toInt()).toList();
    return parsed.length == fallback.length ? parsed : null;
  }

  int? _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    return null;
  }

  double? _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return null;
  }
}
