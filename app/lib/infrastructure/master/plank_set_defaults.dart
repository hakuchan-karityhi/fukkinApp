import "../../domain/models/plank_set.dart";

class PlankSetDefaults {
  const PlankSetDefaults._();

  static const set01 = PlankSetDefinition(
    id: "SET-01",
    name: "プランクセット１",
    plankTypeIds: ["PK-01", "PK-02", "PK-03"],
  );

  static const mvpSets = [set01];
}
