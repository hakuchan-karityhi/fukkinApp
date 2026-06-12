import "package:drift/drift.dart";

import "../../domain/models/custom_plank_type.dart";
import "../../domain/repositories/custom_plank_type_repository.dart";
import "app_database.dart";

class DriftCustomPlankTypeRepository implements CustomPlankTypeRepository {
  DriftCustomPlankTypeRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<CustomPlankType>> getAll() async {
    final rows = await (_db.select(_db.customPlankTypeEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<CustomPlankType?> getById(String id) async {
    final row = await (_db.select(_db.customPlankTypeEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<int> count() async {
    final countExp = _db.customPlankTypeEntries.id.count();
    final query = _db.selectOnly(_db.customPlankTypeEntries)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  @override
  Future<void> save(CustomPlankType type) async {
    await _db.into(_db.customPlankTypeEntries).insertOnConflictUpdate(
          CustomPlankTypeEntriesCompanion.insert(
            id: type.id,
            name: type.name,
            createdAt: type.createdAt,
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.customPlankTypeEntries)..where((t) => t.id.equals(id)))
        .go();
  }

  CustomPlankType _toModel(CustomPlankTypeEntry row) {
    return CustomPlankType(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
    );
  }
}
