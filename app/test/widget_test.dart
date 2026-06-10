import "package:flutter_test/flutter_test.dart";
import "package:fukkin/app/app.dart";

void main() {
  testWidgets("ふっきんアプリが起動する", (WidgetTester tester) async {
    await tester.pumpWidget(const FukkinApp());
    await tester.pump();

    expect(find.text("home"), findsOneWidget);
    expect(find.text("記録"), findsOneWidget);
    expect(find.text("設定"), findsOneWidget);
  });
}
