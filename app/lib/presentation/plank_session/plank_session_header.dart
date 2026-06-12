import "package:flutter/material.dart";

class PlankSessionHeader extends StatelessWidget {
  const PlankSessionHeader({
    super.key,
    required this.plankName,
    this.setName,
    this.progressLabel,
  });

  final String plankName;
  final String? setName;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (setName != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setName!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (progressLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  progressLabel!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(
          plankName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
