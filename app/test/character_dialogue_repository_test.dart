import "package:flutter_test/flutter_test.dart";
import "package:fukkin/infrastructure/master/character_dialogue_repository.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("character_dialogues.json を読み込める", () async {
    final repo = AssetCharacterDialogueRepository();
    final master = await repo.load();

    expect(master.characterName, "かんちゃん");
    expect(master.home["streak_7_13"], isNotEmpty);
    expect(master.sessionCheer["streak_30_plus"], isNotEmpty);
    expect(master.expressions["4"]?.mood, "sparkle");
  });
}
