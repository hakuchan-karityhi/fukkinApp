import "dart:convert";

import "package:flutter/services.dart";

import "../../domain/models/plank_type.dart";
import "../../domain/repositories/plank_type_repository.dart";

class AssetPlankTypeRepository implements PlankTypeRepository {
  static const _assetPath = "assets/master/plank_types.json";

  @override
  Future<List<PlankType>> getAll({required bool betaMode}) async {
    final all = await _loadAll();
    return all
        .where((type) => betaMode ? type.enabledInBeta : type.enabledInMvp)
        .toList();
  }

  @override
  Future<PlankType?> getById(String id) async {
    final all = await _loadAll();
    for (final type in all) {
      if (type.id == id) return type;
    }
    return null;
  }

  Future<List<PlankType>> _loadAll() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final items = decoded["plankTypes"] as List<dynamic>;

    return items
        .map((item) => PlankType.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
