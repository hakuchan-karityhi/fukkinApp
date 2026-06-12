import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../app/providers.dart";
import "../../domain/models/custom_plank_set.dart";
import "../../domain/models/plank_set.dart";
import "../../domain/models/plank_type.dart";
import "../../domain/services/custom_plank_type_mapper.dart";
import "../custom_plank_set/custom_plank_set_editor_screen.dart";
import "../custom_plank_type/custom_plank_type_editor_screen.dart";
import "../plank_session/plank_session_screen.dart";
import "../plank_set/plank_set_session_screen.dart";
import "../widgets/target_seconds_stepper.dart";
import "widgets/add_custom_plank_set_panel.dart";
import "widgets/add_custom_plank_type_panel.dart";
import "widgets/character_panel.dart";
import "widgets/custom_plank_set_carousel_panel.dart";
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

  int _exercisePageCount(int plankCount, int customSetCount) =>
      plankCount + customSetCount + 3;

  int _addPlankPageIndex(int plankCount) => plankCount + 1;

  int _officialSetPageIndex(int plankCount) => plankCount + 2;

  int _addSetPageIndex(int plankCount, int customSetCount) =>
      plankCount + 3 + customSetCount;

  int _activeCarouselIndex({
    required int page,
    required int plankCount,
    required int customSetCount,
  }) {
    if (page <= plankCount) return page - 1;
    if (page == _addPlankPageIndex(plankCount)) return plankCount;
    if (page == _officialSetPageIndex(plankCount)) return plankCount + 1;
    if (page < _addSetPageIndex(plankCount, customSetCount)) {
      return plankCount + 2 + (page - plankCount - 3);
    }
    return plankCount + 2 + customSetCount;
  }

  VoidCallback? _onPreviousPage(int exercisePageCount) {
    if (_currentPage == 0) return null;
    if (_currentPage == 1) return () => _goToPage(0);
    return () => _goToPage(_currentPage - 1);
  }

  VoidCallback _onNextPage(int exercisePageCount) {
    if (_currentPage == 0) return () => _goToPage(1);
    if (_currentPage >= exercisePageCount) return () => _goToPage(1);
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

  Future<void> _startPlankSet({
    required PlankSetDefinition plankSet,
    required List<PlankType> plankTypes,
    required Map<String, int> secondsByPlankId,
  }) async {
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

  Future<void> _openCustomPlankSetEditor({String? existingSetId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomPlankSetEditorScreen(existingSetId: existingSetId),
      ),
    );

    if (saved == true && mounted) {
      ref.invalidate(customPlankSetsProvider);
    }
  }

  void _updateCustomSetSeconds(String setId, String plankId, int seconds) {
    final current = ref.read(customPlankSetTargetSecondsProvider);
    final setSeconds = Map<String, int>.from(current[setId] ?? {});
    setSeconds[plankId] = TargetSeconds.clamp(seconds);
    ref.read(customPlankSetTargetSecondsProvider.notifier).state = {
      ...current,
      setId: setSeconds,
    };
  }

  Map<String, int> _secondsForCustomSet(CustomPlankSet set) {
    final overrides = ref.read(customPlankSetTargetSecondsProvider)[set.id] ?? {};
    return {
      for (final item in set.items)
        item.plankTypeId: TargetSeconds.clamp(
          overrides[item.plankTypeId] ?? item.targetSeconds,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final plankTypesAsync = ref.watch(plankTypesProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final streakAsync = ref.watch(streakStateProvider);
    final officialSet = ref.watch(plankSetDefinitionProvider);
    final officialSetTypesAsync = ref.watch(plankSetPlankTypesProvider);
    final customSetsAsync = ref.watch(customPlankSetsProvider);

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

                final customSets = customSetsAsync.valueOrNull ?? const [];
                final officialSetTypes =
                    officialSetTypesAsync.valueOrNull ?? const [];

                final plankCount = plankTypes.length;
                final customSetCount = customSets.length;
                final exercisePageCount =
                    _exercisePageCount(plankCount, customSetCount);
                final addPlankPage = _addPlankPageIndex(plankCount);
                final officialSetPage = _officialSetPageIndex(plankCount);
                final addSetPage = _addSetPageIndex(plankCount, customSetCount);

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
                final officialSetSeconds =
                    ref.watch(plankSetTargetSecondsProvider);

                final isExercisePage = _currentPage > 0;
                final isAddPlankPage = _currentPage == addPlankPage;
                final isOfficialSetPage = _currentPage == officialSetPage;
                final isAddSetPage = _currentPage == addSetPage;
                final isCustomSetPage = _currentPage > officialSetPage &&
                    _currentPage < addSetPage;
                final customSetIndex =
                    isCustomSetPage ? _currentPage - officialSetPage - 1 : -1;
                final activeCustomSet = isCustomSetPage &&
                        customSetIndex >= 0 &&
                        customSetIndex < customSets.length
                    ? customSets[customSetIndex]
                    : null;

                final activeCarouselIndex = _activeCarouselIndex(
                  page: _currentPage,
                  plankCount: plankCount,
                  customSetCount: customSetCount,
                );

                final activePlank = isOfficialSetPage ||
                        isAddPlankPage ||
                        isAddSetPage ||
                        isCustomSetPage
                    ? null
                    : plankTypes[
                        activeCarouselIndex.clamp(0, plankCount - 1)];

                return Stack(
                  children: [
                    Row(
                      children: [
                        HomeNavArrowButton(
                          icon: Icons.chevron_left,
                          onPressed: _onPreviousPage(exercisePageCount),
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
                                  onEdit: CustomPlankTypeMapper
                                          .isCustomPlankTypeId(plankTypes[i].id)
                                      ? () => _openCustomPlankEditor(
                                            existingId: plankTypes[i].id,
                                          )
                                      : null,
                                ),
                              AddCustomPlankTypePanel(
                                onAdd: () => _openCustomPlankEditor(),
                              ),
                              PlankSetDetailPanel(
                                setName: officialSet.name,
                                plankTypes: officialSetTypes,
                                targetSecondsByPlankId: officialSetSeconds,
                                onTargetSecondsChanged: (plankId, seconds) {
                                  ref
                                      .read(
                                        plankSetTargetSecondsProvider.notifier,
                                      )
                                      .state = {
                                    ...officialSetSeconds,
                                    plankId: TargetSeconds.clamp(seconds),
                                  };
                                },
                              ),
                              for (final set in customSets)
                                CustomPlankSetCarouselPanel(
                                  set: set,
                                  onEdit: () => _openCustomPlankSetEditor(
                                    existingSetId: set.id,
                                  ),
                                  onTargetSecondsChanged: (plankId, seconds) {
                                    _updateCustomSetSeconds(
                                      set.id,
                                      plankId,
                                      seconds,
                                    );
                                  },
                                ),
                              AddCustomPlankSetPanel(
                                onAdd: () => _openCustomPlankSetEditor(),
                              ),
                            ],
                          ),
                        ),
                        HomeNavArrowButton(
                          icon: Icons.chevron_right,
                          onPressed: _onNextPage(exercisePageCount),
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
                                count: exercisePageCount,
                                selectedIndex: activeCarouselIndex,
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
                                    onPressed: () async {
                                      if (isAddPlankPage) {
                                        _openCustomPlankEditor();
                                      } else if (isAddSetPage) {
                                        _openCustomPlankSetEditor();
                                      } else if (isOfficialSetPage) {
                                        await _startPlankSet(
                                          plankSet: officialSet,
                                          plankTypes: officialSetTypes,
                                          secondsByPlankId: officialSetSeconds,
                                        );
                                      } else if (activeCustomSet != null) {
                                        final types =
                                            CustomPlankSetCarouselPanel
                                                .resolvePlankTypes(
                                          plankTypes,
                                          activeCustomSet,
                                        );
                                        await _startPlankSet(
                                          plankSet:
                                              activeCustomSet.toDefinition(),
                                          plankTypes: types,
                                          secondsByPlankId:
                                              _secondsForCustomSet(
                                            activeCustomSet,
                                          ),
                                        );
                                      } else if (activePlank != null) {
                                        final seconds = TargetSeconds.clamp(
                                          ref.read(targetSecondsProvider) ??
                                              activePlank.defaultSeconds,
                                        );
                                        await _startPlank(
                                          activePlank,
                                          seconds,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      isAddPlankPage || isAddSetPage
                                          ? Icons.add
                                          : Icons.play_arrow,
                                      size: 24,
                                    ),
                                    label: Text(
                                      isAddPlankPage
                                          ? "種目を追加"
                                          : isAddSetPage
                                              ? "セットを作る"
                                              : "スタート",
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
