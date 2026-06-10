import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/character_dialogues.dart";
import "package:fukkin/domain/models/streak_state.dart";
import "package:fukkin/domain/services/character_dialogue_selector.dart";

void main() {
  const selector = CharacterDialogueSelector();

  const master = CharacterDialogues(
    characterName: "かんちゃん",
    home: {
      "comeback": ["おかえり"],
      "streak_at_risk": ["{streak}日を守ろう"],
      "evening_not_done": ["今日まだだね"],
      "streak_1_2": ["はじめの一歩"],
      "streak_3_6": ["3日目いい感じ"],
      "streak_7_13": ["7日すごい"],
      "streak_14_29": ["14日すごい"],
      "streak_30_plus": ["30日伝説"],
    },
    sessionCheer: {
      "streak_1_2": ["いい姿勢"],
      "streak_3_6": ["いいペース"],
      "streak_7_13": ["7日目の力"],
      "streak_14_29": ["長いストリーク"],
      "streak_30_plus": ["伝説級"],
    },
    expressions: {
      "0": CharacterExpression(mood: "neutral", label: "ふつう"),
      "4": CharacterExpression(mood: "sparkle", label: "きらきら"),
    },
  );

  test("ストリーク帯の判定", () {
    expect(selector.streakBand(1), StreakBand.streak1_2);
    expect(selector.streakBand(3), StreakBand.streak3_6);
    expect(selector.streakBand(7), StreakBand.streak7_13);
    expect(selector.streakBand(14), StreakBand.streak14_29);
    expect(selector.streakBand(30), StreakBand.streak30Plus);
  });

  test("復帰コンテキストを優先する", () {
    const streak = StreakState(
      currentStreak: 0,
      longestStreak: 10,
      todayCompleted: false,
    );

    expect(
      selector.homeDialogue(
        master: master,
        streak: streak,
        now: DateTime(2026, 6, 11, 18),
      ),
      "おかえり",
    );
  });

  test("夕方のストリーク危機セリフ", () {
    const streak = StreakState(
      currentStreak: 5,
      longestStreak: 5,
      todayCompleted: false,
    );

    expect(
      selector.homeDialogue(
        master: master,
        streak: streak,
        now: DateTime(2026, 6, 11, 18),
      ),
      "5日を守ろう",
    );
  });

  test("ストリーク帯でホームセリフが変化する", () {
    const streak = StreakState(
      currentStreak: 8,
      longestStreak: 8,
      todayCompleted: true,
    );

    expect(
      selector.homeDialogue(
        master: master,
        streak: streak,
        now: DateTime(2026, 6, 11, 10),
      ),
      isNot("はじめの一歩"),
    );
  });

  test("実行中の応援セリフがストリーク帯で変化する", () {
    final low = selector.sessionCheer(
      master: master,
      currentStreak: 2,
      now: DateTime(2026, 6, 11),
    );
    final high = selector.sessionCheer(
      master: master,
      currentStreak: 30,
      now: DateTime(2026, 6, 11),
    );

    expect(low, "いい姿勢");
    expect(high, "伝説級");
  });

  test("腹筋ステージの表情キー", () {
    expect(selector.expressionKey(0), "0");
    expect(selector.expressionKey(4), "4");
    expect(selector.expressionKey(99), "4");
  });
}
