import "dart:convert";

import "package:flutter/services.dart";

import "../../domain/models/character_dialogues.dart";
import "../../domain/repositories/character_dialogue_repository.dart";

class AssetCharacterDialogueRepository implements CharacterDialogueRepository {
  static const _assetPath = "assets/master/character_dialogues.json";

  @override
  Future<CharacterDialogues> load() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return CharacterDialogues.fromJson(decoded);
  }
}
