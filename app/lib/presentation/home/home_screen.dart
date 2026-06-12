import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../plank_session/plank_session_screen.dart";
import "../plank_set/plank_set_session_screen.dart";
import "widgets/character_panel.dart";
import "widgets/exercise_panel.dart";
import "widgets/home_header.dart";
import "widgets/plank_set_panel.dart";

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
    if (page > 0 && page <= plankTypes.length) {
      final plankIndex = page - 1;
      ref.read(selectedPlankIndexProvider.notifier).state = plankIndex;
      ref.read(targetSecondsProvider.notifier).state =
          plankTypes[plankIndex].defaultSeconds;
    }
  }

  VoidCallback? _onPreviousPage(int exerciseCount) {
    if (_currentPage == 0) return null;
    if (_currentPage == 1) return () => _goToPage(0);
    return () => _goToPage(_currentPage - 1);
  }

  VoidCallback _onNextPage(int exerciseCount) {
    if (_currentPage == 0) return () => _goToPage(1);
    if (_currentPage >= exerciseCount) return () => _goToPage(1);
    return () => _goToPage(_currentPage + 1);
  }

  Future<void> _startPlank(PlankType plankType, int targetSeconds) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlankSessionScreen(
          plankType: plankType,
          targetSeconds: targetSeconds,
        ),
      ),
    );

    if (!mounted) return;
    _invalidateHomeData();
  }

  Future<void> _startPlankSet(int targetSeconds) async {
    final plankSet = ref.read(plankSetDefinitionProvider);
    final plankTypes = await ref.read(plankSetPlankTypesProvider.future);

    if (plankTypes.length != plankSet.plankTypeIds.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("プランクセットの種目を読み込めませんでした")),
      );
      return;
    }

    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlankSetSessionScreen(
          plankSet: plankSet,
          plankTypes: plankTypes,
          targetSeconds: targetSeconds,
        ),
      ),
    );

    if (!mounted) return;
    _invalidateHomeData();
  }

  void _invalidateHomeData() {
    ref.invalidate(userProgressProvider);
    ref.invalidate(streakStateProvider);
    ref.invalidate(milestoneAchievementsProvider);
    ref.invalidate(todayWorkoutSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final plankTypesAsync = ref.watch(plankTypesProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final streakAsync = ref.watch(streakStateProvider);
    final plankSet = ref.watch(plankSetDefinitionProvider);
    final plankSetTypesAsync = ref.watch(plankSetPlankTypesProvider);

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

                final plankSetTypes = plankSetTypesAsync.valueOrNull ?? const [];

                final exerciseCount = plankTypes.length + 1;
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
                final isPlankSetPage = _currentPage == exerciseCount;
                final activePlankIndex = isPlankSetPage
                    ? plankTypes.length
                    : (isExercisePage ? _currentPage - 1 : clampedIndex);
                final activePlank = isPlankSetPage
                    ? null
                    : plankTypes[activePlankIndex.clamp(0, plankTypes.length - 1)];

                return Stack(
                  children: [
                    Row(
                      children: [
                        HomeNavArrowButton(
                          icon: Icons.chevron_left,
                          onPressed: _onPreviousPage(exerciseCount),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const ClampingScrollPhysics(),
                            onPageChanged: (page) =>
                                _onPageChanged(page, plankTypes),
                            children: [
                              CharacterPanel(
                                progressAsync: progressAsync,
                                streakAsync: streakAsync,
                              ),
                              for (var i = 0; i < plankTypes.length; i++)
                                PlankDetailPanel(
                                  plank: plankTypes[i],
                                  targetSeconds: targetSeconds,
                                  onTargetSecondsChanged: (seconds) {
                                    ref
                                        .read(targetSecondsProvider.notifier)
                                        .state = seconds;
                                  },
                                ),
                              PlankSetDetailPanel(
                                setName: plankSet.name,
                                plankTypes: plankSetTypes,
                                targetSeconds: targetSeconds,
                              ),
                            ],
                          ),
                        ),
                        HomeNavArrowButton(
                          icon: Icons.chevron_right,
                          onPressed: _onNextPage(exerciseCount),
                        ),
                      ],
                    ),
                    if (isExercisePage) ...[
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            "種目を選ぶ",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withValues(alpha: 0.96),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              CarouselIndicator(
                                count: exerciseCount,
                                selectedIndex: activePlankIndex,
                                onDotTap: (index) => _goToPage(index + 1),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      if (isPlankSetPage) {
                                        _startPlankSet(targetSeconds);
                                      } else if (activePlank != null) {
                                        _startPlank(
                                          activePlank,
                                          targetSeconds,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.play_arrow, size: 24),
                                    label: const Text(
                                      "スタート",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
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
