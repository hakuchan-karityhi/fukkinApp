import "../models/game_constants.dart";

abstract class GameConstantsRepository {
  Future<GameConstants> load();
}
