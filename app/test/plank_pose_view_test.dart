import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:fukkin/domain/models/plank_type.dart";
import "package:fukkin/presentation/widgets/plank_pose_view.dart";

void main() {
  testWidgets("種目ごとに異なるポーズアイコンを表示", (tester) async {
    const basic = PlankType(
      id: "PK-01",
      name: "ベーシック",
      difficulty: 1,
      expMultiplier: 1.0,
      defaultSeconds: 30,
      enabledInMvp: true,
      enabledInBeta: true,
      poseAssetId: "basic_plank",
      formImageAsset: "",
      recommendedSecondsMin: 30,
      recommendedSecondsMax: 60,
    );
    const spider = PlankType(
      id: "PK-07",
      name: "スパイダー",
      difficulty: 3,
      expMultiplier: 1.3,
      defaultSeconds: 30,
      enabledInMvp: false,
      enabledInBeta: true,
      poseAssetId: "spider_plank",
      formImageAsset: "",
      recommendedSecondsMin: 20,
      recommendedSecondsMax: 40,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: const [
              PlankPoseView(plankType: basic, showLabel: false),
              PlankPoseView(plankType: spider, showLabel: false),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    expect(find.byIcon(Icons.bug_report), findsOneWidget);
  });
}
