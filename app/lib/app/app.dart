import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../presentation/main/main_shell.dart";
import "theme.dart";

class FukkinApp extends StatelessWidget {
  const FukkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: "ふっきん",
        theme: fukkinTheme,
        home: const MainShell(),
      ),
    );
  }
}
