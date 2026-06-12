import "package:flutter/material.dart";

import "../album/album_screen.dart";
import "../home/home_screen.dart";
import "../records/records_screen.dart";
import "../settings/settings_screen.dart";

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _TabItem(label: "home", icon: Icons.home_outlined),
    _TabItem(label: "記録", icon: Icons.calendar_month_outlined),
    _TabItem(label: "アルバム", icon: Icons.collections_outlined),
    _TabItem(label: "設定", icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          RecordsScreen(),
          AlbumScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
