import "package:flutter/material.dart";

import "dialogue_bubble.dart";

class ResultCharacterGreeting extends StatelessWidget {
  const ResultCharacterGreeting({super.key});

  static const _characterImageAsset = "assets/character/kangaru1.png";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              _characterImageAsset,
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 140,
            bottom: 168,
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(
                      bodyMedium: Theme.of(context).textTheme.titleMedium,
                    ),
              ),
              child: DialogueBubble(
                text: "お疲れ様でした",
                maxWidth: 280,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
