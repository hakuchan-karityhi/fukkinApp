import "../models/plank_type.dart";

abstract class PlankTypeRepository {
  Future<List<PlankType>> getAll({required bool betaMode});
  Future<PlankType?> getById(String id);
}
