import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/presentation/records/widgets/month_calendar.dart";

void main() {
  testWidgets("日付タップで onDateSelected が呼ばれる", (WidgetTester tester) async {
    DateTime? tappedDate;

    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonthCalendar(
            year: 2026,
            month: 6,
            workoutDates: {DateTime(2026, 6, 5)},
            selectedDate: DateTime(2026, 6, 1),
            onDateSelected: (date) => tappedDate = date,
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text("11"));
    await tester.pumpAndSettle();

    expect(tappedDate, DateTime(2026, 6, 11));
  });
}
