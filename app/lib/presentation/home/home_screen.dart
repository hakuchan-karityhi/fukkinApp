import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../plank_session/plank_session_screen.dart";
import "widgets/character_panel.dart";
import "widgets/exercise_panel.dart";
import "widgets/home_header.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPanel(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _startPlank(PlankType plankType, int targetSeconds) async {
    final result = await Navigator.of(context, rootNavigator: true).push<dynamic>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PlankSessionScreen(
          plankType: plankType,
          targetSeconds: targetSeconds,
        ),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(userProgressProvider);
      ref.invalidate(streakStateProvider);
      final now = DateTime.now();
      ref.invalidate(
        workoutRecordsForMonthProvider(DateTime(now.year, now.month)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plankTypesAsync = ref.watch(plankTypesProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final streakAsync = ref.watch(streakStateProvider);

    return SafeArea(
      child: Column(
        children: [
          HomeHeader(
            progressAsync: progressAsync,
            streakAsync: streakAsync,
          ),
          Expanded(
            child: plankTypesAsync.when(
              data: (plankTypes) {
                if (plankTypes.isEmpty) {
                  return const Center(child: Text("種目がありません"));
                }

                final selectedIndex = ref.watch(selectedPlankIndexProvider);
                final clampedIndex =
                    selectedIndex.clamp(0, plankTypes.length - 1);
                if (selectedIndex != clampedIndex) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedPlankIndexProvider.notifier).state =
                        clampedIndex;
                  });
                }

                final selectedPlank = plankTypes[clampedIndex];
                final targetSeconds = ref.watch(targetSecondsProvider) ??
                    selectedPlank.defaultSeconds;

                return PageView(
                  controller: _pageController,
                  children: [
                    CharacterPanel(
                      progressAsync: progressAsync,
                      onNext: () => _goToPanel(1),
                    ),
                    ExercisePanel(
                      plankTypes: plankTypes,
                      selectedIndex: clampedIndex,
                      targetSeconds: targetSeconds,
                      streakAsync: streakAsync,
                      onPreviousPanel: () => _goToPanel(0),
                      onSelectPlank: (index) {
                        ref.read(selectedPlankIndexProvider.notifier).state =
                            index;
                        ref.read(targetSecondsProvider.notifier).state =
                            plankTypes[index].defaultSeconds;
                      },
                      onTargetSecondsChanged: (seconds) {
                        ref.read(targetSecondsProvider.notifier).state = seconds;
                      },
                      onStart: () => _startPlank(selectedPlank, targetSeconds),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }
}
