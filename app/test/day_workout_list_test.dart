import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/workout_record.dart";
import "package:fukkin/presentation/records/widgets/day_workout_list.dart";

void main() {
  testWidgets("記録がない日は空状態を表示する", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayWorkoutList(
            selectedDate: DateTime(2026, 6, 11),
            records: const [],
            plankTypeNames: const {},
          ),
        ),
      ),
    );

    expect(find.text("2026年6月11日の記録"), findsOneWidget);
    expect(find.text("この日は記録がありません"), findsOneWidget);
  });

  testWidgets("同日複数回の記録をすべて表示する", (WidgetTester tester) async {
    final records = [
      WorkoutRecord(
        id: "1",
        date: DateTime(2026, 6, 11),
        plankTypeId: "PK-01",
        targetSeconds: 30,
        earnedExp: 30,
        completedAt: DateTime(2026, 6, 11, 8, 30),
        sessionIndexOfDay: 1,
      ),
      WorkoutRecord(
        id: "2",
        date: DateTime(2026, 6, 11),
        plankTypeId: "PK-02",
        targetSeconds: 45,
        earnedExp: 50,
        completedAt: DateTime(2026, 6, 11, 20, 15),
        sessionIndexOfDay: 2,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayWorkoutList(
            selectedDate: DateTime(2026, 6, 11),
            records: records,
            plankTypeNames: const {
              "PK-01": "ベーシックプランク",
              "PK-02": "ニープランク",
            },
          ),
        ),
      ),
    );

    expect(find.text("ベーシックプランク"), findsOneWidget);
    expect(find.text("ニープランク"), findsOneWidget);
    expect(find.textContaining("30秒"), findsOneWidget);
    expect(find.textContaining("45秒"), findsOneWidget);
    expect(find.textContaining("1回目"), findsOneWidget);
    expect(find.textContaining("2回目"), findsOneWidget);
  });
}
