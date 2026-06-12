import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/plank_type.dart";
import "../../domain/services/custom_plank_type_mapper.dart";
import "../custom_plank_type/custom_plank_type_editor_screen.dart";
import "../plank_session/plank_session_screen.dart";
import "../plank_set/plank_set_session_screen.dart";
import "../widgets/target_seconds_stepper.dart";
import "widgets/add_custom_plank_type_panel.dart";
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
      ref.read(targetSecondsProvider.notifier).state = TargetSeconds.clamp(
        plankTypes[plankIndex].defaultSeconds,
      );
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

  Future<void> _startPlankSet(List<PlankType> plankTypes) async {
    final plankSet = ref.read(plankSetDefinitionProvider);
    final secondsByPlankId = ref.read(plankSetTargetSecondsProvider);

    if (plankTypes.length != plankSet.plankTypeIds.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("プランクセットの種目を読み込めませんでした")),
      );
      return;
    }

    final targetSecondsList = [
      for (final plank in plankTypes)
        TargetSeconds.clamp(
          secondsByPlankId[plank.id] ?? plank.defaultSeconds,
        ),
    ];

    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlankSetSessionScreen(
          plankSet: plankSet,
          plankTypes: plankTypes,
          targetSecondsList: targetSecondsList,
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

  Future<void> _openCustomPlankEditor({String? existingId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomPlankTypeEditorScreen(existingId: existingId),
      ),
    );

    if (saved == true && mounted) {
      ref.invalidate(customPlankTypesProvider);
      ref.invalidate(plankTypesProvider);
    }
  }

  int _addPageIndex(int plankCount) => plankCount + 1;

  int _setPageIndex(int plankCount) => plankCount + 2;

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

                final plankCount = plankTypes.length;
                final exerciseCount = plankCount + 2;
                final addPageIndex = _addPageIndex(plankCount);
                final setPageIndex = _setPageIndex(plankCount);
                final selectedIndex = ref.watch(selectedPlankIndexProvider);
                final clampedIndex = selectedIndex.clamp(0, plankCount - 1);
                if (selectedIndex != clampedIndex) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedPlankIndexProvider.notifier).state =
                        clampedIndex;
                  });
                }

                final targetSeconds = TargetSeconds.clamp(
                  ref.watch(targetSecondsProvider) ??
                      plankTypes[clampedIndex].defaultSeconds,
                );
                final plankSetSeconds =
                    ref.watch(plankSetTargetSecondsProvider);
                final isExercisePage = _currentPage > 0;
                final isAddPage = _currentPage == addPageIndex;
                final isPlankSetPage = _currentPage == setPageIndex;
                final activePlankIndex = isPlankSetPage
                    ? plankCount + 1
                    : isAddPage
                        ? plankCount
                        : (isExercisePage ? _currentPage - 1 : clampedIndex);
                final activePlank = isPlankSetPage || isAddPage
                    ? null
                    : plankTypes[activePlankIndex.clamp(0, plankCount - 1)];

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
                                        .state = TargetSeconds.clamp(seconds);
                                  },
                                  onEdit: CustomPlankTypeMapper.isCustomPlankTypeId(
                                    plankTypes[i].id,
                                  )
                                      ? () => _openCustomPlankEditor(
                                            existingId: plankTypes[i].id,
                                          )
                                      : null,
                                ),
                              AddCustomPlankTypePanel(
                                onAdd: () => _openCustomPlankEditor(),
                              ),
                              PlankSetDetailPanel(
                                setName: plankSet.name,
                                plankTypes: plankSetTypes,
                                targetSecondsByPlankId: plankSetSeconds,
                                onTargetSecondsChanged: (plankId, seconds) {
                                  ref
                                      .read(
                                        plankSetTargetSecondsProvider.notifier,
                                      )
                                      .state = {
                                    ...plankSetSeconds,
                                    plankId: TargetSeconds.clamp(seconds),
                                  };
                                },
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
                                      if (isAddPage) {
                                        _openCustomPlankEditor();
                                      } else if (isPlankSetPage) {
                                        _startPlankSet(plankSetTypes);
                                      } else if (activePlank != null) {
                                        final seconds = TargetSeconds.clamp(
                                          ref.read(targetSecondsProvider) ??
                                              activePlank.defaultSeconds,
                                        );
                                        _startPlank(activePlank, seconds);
                                      }
                                    },
                                    icon: Icon(
                                      isAddPage
                                          ? Icons.add
                                          : Icons.play_arrow,
                                      size: 24,
                                    ),
                                    label: Text(
                                      isAddPage ? "種目を追加" : "スタート",
                                      style: const TextStyle(
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
