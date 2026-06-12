import "../../domain/models/game_constants.dart";
import "../../domain/repositories/game_constants_repository.dart";

/// アプリ内蔵デフォルト。オフライン・Remote Config 未取得時のフォールバック。
class LocalGameConstantsRepository implements GameConstantsRepository {
  @override
  Future<GameConstants> load() async => GameConstants.defaults();
}
