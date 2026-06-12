import "../models/character_dialogues.dart";

abstract class CharacterDialogueRepository {
  Future<CharacterDialogues> load();
}
