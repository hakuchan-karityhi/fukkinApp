import "../models/character_dialogues.dart";
import "../models/streak_state.dart";

enum StreakBand {
  streak1_2,
  streak3_6,
  streak7_13,
  streak14_29,
  streak30Plus,
}

enum HomeDialogueContext {
  comeback,
  streakAtRisk,
  eveningNotDone,
  streakBand,
}

class CharacterDialogueSelector {
  const CharacterDialogueSelector();

  static const eveningHour = 17;

  StreakBand streakBand(int streak) {
    if (streak >= 30) return StreakBand.streak30Plus;
    if (streak >= 14) return StreakBand.streak14_29;
    if (streak >= 7) return StreakBand.streak7_13;
    if (streak >= 3) return StreakBand.streak3_6;
    return StreakBand.streak1_2;
  }

  String streakBandKey(StreakBand band) {
    return switch (band) {
      StreakBand.streak1_2 => "streak_1_2",
      StreakBand.streak3_6 => "streak_3_6",
      StreakBand.streak7_13 => "streak_7_13",
      StreakBand.streak14_29 => "streak_14_29",
      StreakBand.streak30Plus => "streak_30_plus",
    };
  }

  HomeDialogueContext homeContext({
    required StreakState streak,
    required DateTime now,
  }) {
    if (isComeback(streak)) return HomeDialogueContext.comeback;
    if (isStreakAtRisk(streak, now)) {
      return HomeDialogueContext.streakAtRisk;
    }
    if (isEveningNotDone(streak, now)) {
      return HomeDialogueContext.eveningNotDone;
    }
    return HomeDialogueContext.streakBand;
  }

  bool isComeback(StreakState streak) {
    return streak.currentStreak == 0 && streak.longestStreak > 0;
  }

  bool isStreakAtRisk(StreakState streak, DateTime now) {
    if (streak.currentStreak <= 0 || streak.todayCompleted) return false;
    return now.hour >= eveningHour;
  }

  bool isEveningNotDone(StreakState streak, DateTime now) {
    if (streak.todayCompleted) return false;
    return now.hour >= eveningHour;
  }

  String homeDialogue({
    required CharacterDialogues master,
    required StreakState streak,
    required DateTime now,
  }) {
    final context = homeContext(streak: streak, now: now);
    final key = switch (context) {
      HomeDialogueContext.comeback => "comeback",
      HomeDialogueContext.streakAtRisk => "streak_at_risk",
      HomeDialogueContext.eveningNotDone => "evening_not_done",
      HomeDialogueContext.streakBand =>
        streakBandKey(streakBand(streak.currentStreak)),
    };

    final lines = master.home[key] ?? master.home["streak_1_2"]!;
    final line = _pickLine(lines, _seed(now, streak.currentStreak, key));
    return _format(line, streak.currentStreak);
  }

  String sessionCheer({
    required CharacterDialogues master,
    required int currentStreak,
    required DateTime now,
    int rotationIndex = 0,
  }) {
    final key = streakBandKey(streakBand(currentStreak));
    final lines = master.sessionCheer[key] ?? master.sessionCheer["streak_1_2"]!;
    final line = _pickLine(
      lines,
      _seed(now, currentStreak, key) + rotationIndex,
    );
    return _format(line, currentStreak);
  }

  String expressionKey(int absStage) {
    return absStage.clamp(0, 4).toString();
  }

  String _format(String template, int streak) {
    return template.replaceAll("{streak}", "$streak");
  }

  String _pickLine(List<String> lines, int seed) {
    if (lines.isEmpty) return "";
    return lines[seed % lines.length];
  }

  int _seed(DateTime now, int streak, String key) {
    return now.year * 1000 +
        now.month * 100 +
        now.day +
        streak * 7 +
        key.hashCode;
  }
}
