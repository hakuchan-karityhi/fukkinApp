import "../models/custom_plank_set.dart";

abstract class CustomPlankSetRepository {
  Future<List<CustomPlankSet>> getAll();

  Future<CustomPlankSet?> getById(String id);

  Future<void> save(CustomPlankSet set);

  Future<void> delete(String id);
}
