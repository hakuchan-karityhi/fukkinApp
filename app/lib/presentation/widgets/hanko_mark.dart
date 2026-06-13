import "package:flutter/material.dart";

class HankoMark extends StatelessWidget {
  const HankoMark({super.key, required this.size});

  final double size;

  static const _stampColor = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _stampColor, width: size * 0.07),
      ),
      alignment: Alignment.center,
      child: Text(
        "済",
        style: TextStyle(
          color: _stampColor.withValues(alpha: 0.88),
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
