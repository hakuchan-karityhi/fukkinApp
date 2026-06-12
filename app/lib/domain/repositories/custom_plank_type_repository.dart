import "../models/custom_plank_type.dart";

abstract class CustomPlankTypeRepository {
  Future<List<CustomPlankType>> getAll();

  Future<CustomPlankType?> getById(String id);

  Future<int> count();

  Future<void> save(CustomPlankType type);

  Future<void> delete(String id);
}
