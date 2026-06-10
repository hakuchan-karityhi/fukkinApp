import "package:flutter_test/flutter_test.dart";
import "package:fukkin/app/app.dart";

void main() {
  testWidgets("ふっきんアプリが起動する", (WidgetTester tester) async {
    await tester.pumpWidget(const FukkinApp());
    await tester.pumpAndSettle();

    expect(find.text("ふっきん"), findsOneWidget);
    expect(find.text("開発基盤 Ready"), findsOneWidget);
  });
}
