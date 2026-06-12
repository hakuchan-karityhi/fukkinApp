import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/presentation/widgets/target_seconds_stepper.dart";

void main() {
  group("TargetSeconds", () {
    test("5秒刻みでクランプする", () {
      expect(TargetSeconds.clamp(12), 10);
      expect(TargetSeconds.clamp(33), 35);
      expect(TargetSeconds.clamp(122), 120);
    });

    test("増減は5秒単位", () {
      expect(TargetSeconds.decrement(30), 25);
      expect(TargetSeconds.increment(30), 35);
      expect(TargetSeconds.decrement(10), isNull);
      expect(TargetSeconds.increment(120), isNull);
    });
  });

  testWidgets("− + で秒数が5秒ずつ変わる", (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: _StepperHarness()));

    expect(find.text("30秒"), findsOneWidget);

    await tester.tap(find.text("+"));
    await tester.pumpAndSettle();
    expect(find.text("35秒"), findsOneWidget);

    await tester.tap(find.text("−"));
    await tester.pumpAndSettle();
    expect(find.text("30秒"), findsOneWidget);
  });

  testWidgets("最小・最大でボタンが無効になる", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TargetSecondsStepper(
            seconds: 10,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final minusButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text("−"),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(minusButton.onPressed, isNull);
  });
}

class _StepperHarness extends StatefulWidget {
  const _StepperHarness();

  @override
  State<_StepperHarness> createState() => _StepperHarnessState();
}

class _StepperHarnessState extends State<_StepperHarness> {
  var _seconds = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TargetSecondsStepper(
        seconds: _seconds,
        onChanged: (value) => setState(() => _seconds = value),
      ),
    );
  }
}
