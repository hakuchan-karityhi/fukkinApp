import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/presentation/widgets/exp_gain_progress_bar.dart";

void main() {
  testWidgets("EXPバーと加算表示が描画される", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpGainProgressBar(
            totalExpBefore: 100,
            totalExpAfter: 130,
            earnedExp: 30,
            levelThresholds: [150, 400, 800, 1400],
            autoStart: false,
          ),
        ),
      ),
    );

    expect(find.text("Lv 1"), findsOneWidget);
    expect(find.text("+0 EXP"), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
