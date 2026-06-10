import "package:flutter/material.dart";

import "../../domain/models/character_dialogues.dart";

class CharacterExpressionView extends StatelessWidget {
  const CharacterExpressionView({
    super.key,
    required this.absStage,
    required this.expression,
    this.size = 120,
  });

  final int absStage;
  final CharacterExpression expression;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stage = absStage.clamp(0, 4);
    final style = _styleFor(stage, expression.mood);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: style.color.withValues(alpha: 0.4), width: 2),
          ),
          child: Icon(style.icon, size: size * 0.55, color: style.color),
        ),
        const SizedBox(height: 6),
        Text(
          expression.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: style.color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  _ExpressionStyle _styleFor(int stage, String mood) {
    final base = switch (mood) {
      "happy" => const _ExpressionStyle(Icons.sentiment_satisfied_alt, Color(0xFF66BB6A)),
      "cheer" => const _ExpressionStyle(Icons.emoji_emotions_outlined, Color(0xFF42A5F5)),
      "proud" => const _ExpressionStyle(Icons.military_tech_outlined, Color(0xFFFFA726)),
      "sparkle" => const _ExpressionStyle(Icons.auto_awesome, Color(0xFFAB47BC)),
      _ => const _ExpressionStyle(Icons.pets, Color(0xFF90A4AE)),
    };

    if (stage <= 0) {
      return const _ExpressionStyle(Icons.pets, Color(0xFF90A4AE));
    }
    return base;
  }
}

class _ExpressionStyle {
  const _ExpressionStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}
