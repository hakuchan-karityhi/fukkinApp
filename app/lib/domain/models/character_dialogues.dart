class CharacterDialogues {
  const CharacterDialogues({
    required this.characterName,
    required this.home,
    required this.sessionCheer,
    required this.expressions,
  });

  final String characterName;
  final Map<String, List<String>> home;
  final Map<String, List<String>> sessionCheer;
  final Map<String, CharacterExpression> expressions;

  factory CharacterDialogues.fromJson(Map<String, dynamic> json) {
    final homeJson = json["home"] as Map<String, dynamic>;
    final cheerJson = json["sessionCheer"] as Map<String, dynamic>;
    final expressionsJson = json["expressions"] as Map<String, dynamic>;

    return CharacterDialogues(
      characterName: json["characterName"] as String,
      home: homeJson.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).cast<String>(),
        ),
      ),
      sessionCheer: cheerJson.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).cast<String>(),
        ),
      ),
      expressions: expressionsJson.map(
        (key, value) => MapEntry(
          key,
          CharacterExpression.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class CharacterExpression {
  const CharacterExpression({
    required this.mood,
    required this.label,
  });

  final String mood;
  final String label;

  factory CharacterExpression.fromJson(Map<String, dynamic> json) {
    return CharacterExpression(
      mood: json["mood"] as String,
      label: json["label"] as String,
    );
  }
}
