import "package:drift/drift.dart";

import "../../domain/models/custom_plank_set.dart";
import "../../domain/repositories/custom_plank_set_repository.dart";
import "app_database.dart";

class DriftCustomPlankSetRepository implements CustomPlankSetRepository {
  DriftCustomPlankSetRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<CustomPlankSet>> getAll() async {
    final sets = await (_db.select(_db.customPlankSetEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
    final result = <CustomPlankSet>[];
    for (final set in sets) {
      final items = await (_db.select(_db.customPlankSetItemEntries)
            ..where((t) => t.setId.equals(set.id))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      result.add(
        CustomPlankSet(
          id: set.id,
          name: set.name,
          updatedAt: set.updatedAt,
          items: [
            for (final item in items)
              CustomPlankSetItem(
                plankTypeId: item.plankTypeId,
                targetSeconds: item.targetSeconds,
              ),
          ],
        ),
      );
    }
    return result;
  }

  @override
  Future<CustomPlankSet?> getById(String id) async {
    final set = await (_db.select(_db.customPlankSetEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (set == null) return null;

    final items = await (_db.select(_db.customPlankSetItemEntries)
          ..where((t) => t.setId.equals(id))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return CustomPlankSet(
      id: set.id,
      name: set.name,
      updatedAt: set.updatedAt,
      items: [
        for (final item in items)
          CustomPlankSetItem(
            plankTypeId: item.plankTypeId,
            targetSeconds: item.targetSeconds,
          ),
      ],
    );
  }

  @override
  Future<void> save(CustomPlankSet set) async {
    await _db.transaction(() async {
      await _db.into(_db.customPlankSetEntries).insertOnConflictUpdate(
            CustomPlankSetEntriesCompanion.insert(
              id: set.id,
              name: set.name,
              updatedAt: set.updatedAt,
            ),
          );

      await (_db.delete(_db.customPlankSetItemEntries)
            ..where((t) => t.setId.equals(set.id)))
          .go();

      for (var i = 0; i < set.items.length; i++) {
        final item = set.items[i];
        await _db.into(_db.customPlankSetItemEntries).insert(
              CustomPlankSetItemEntriesCompanion.insert(
                setId: set.id,
                sortOrder: i,
                plankTypeId: item.plankTypeId,
                targetSeconds: item.targetSeconds,
              ),
            );
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.customPlankSetEntries)..where((t) => t.id.equals(id)))
        .go();
  }
}
