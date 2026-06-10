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
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page, List<PlankType> plankTypes) {
    setState(() => _currentPage = page);
    if (page > 0) {
      final plankIndex = page - 1;
      ref.read(selectedPlankIndexProvider.notifier).state = plankIndex;
      ref.read(targetSecondsProvider.notifier).state =
          plankTypes[plankIndex].defaultSeconds;
    }
  }

  Future<void> _startPlank(PlankType plankType, int targetSeconds) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => PlankSessionScreen(
          plankType: plankType,
          targetSeconds: targetSeconds,
        ),
      ),
    );

    if (result != null && mounted) {
      ref.invalidate(userProgressProvider);
      ref.invalidate(streakStateProvider);
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

                final targetSeconds = ref.watch(targetSecondsProvider) ??
                    plankTypes[clampedIndex].defaultSeconds;

                final isExercisePage = _currentPage > 0;

                return Column(
                  children: [
                    if (isExercisePage)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "種目を選ぶ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              "$_currentPage / ${plankTypes.length}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    if (isExercisePage) const SizedBox(height: 8),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) =>
                            _onPageChanged(page, plankTypes),
                        children: [
                          CharacterPanel(
                            progressAsync: progressAsync,
                            onNext: () => _goToPage(1),
                          ),
                          for (var i = 0; i < plankTypes.length; i++)
                            ExercisePanel(
                              plank: plankTypes[i],
                              targetSeconds: targetSeconds,
                              streakAsync: streakAsync,
                              onPrevious: () => _goToPage(i),
                              onNext: i < plankTypes.length - 1
                                  ? () => _goToPage(i + 2)
                                  : null,
                              onTargetSecondsChanged: (seconds) {
                                ref.read(targetSecondsProvider.notifier).state =
                                    seconds;
                              },
                              onStart: () => _startPlank(
                                plankTypes[i],
                                targetSeconds,
                              ),
                            ),
                        ],
                      ),
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
