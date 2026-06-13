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
  static const _horizontalHomePage = 0;
  static const _horizontalPlankPage = 1;
  static const _horizontalSetPage = 2;

  final _horizontalPageController = PageController();
  final _plankPageController = PageController();
  final _setPageController = PageController();

  int _horizontalPage = 0;
  int _plankVerticalPage = 0;
  int _setVerticalPage = 0;

  @override
  void dispose() {
    _horizontalPageController.dispose();
    _plankPageController.dispose();
    _setPageController.dispose();
    super.dispose();
  }

  void _goToHorizontalPage(int page) {
    _horizontalPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPlankVerticalPageChanged(int page, List<PlankType> plankTypes) {
    setState(() => _plankVerticalPage = page);
    if (page < plankTypes.length) {
      ref.read(selectedPlankIndexProvider.notifier).state = page;
      ref.read(targetSecondsProvider.notifier).state = TargetSeconds.clamp(
        plankTypes[page].defaultSeconds,
      );
    }
  }

  VoidCallback? _onPreviousHorizontal() {
    if (_horizontalPage == _horizontalHomePage) return null;
    return () => _goToHorizontalPage(_horizontalPage - 1);
  }

  VoidCallback? _onNextHorizontal() {
    if (_horizontalPage == _horizontalSetPage) return null;
    return () => _goToHorizontalPage(_horizontalPage + 1);
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

  Future<void> _onStartPressed({
    required List<PlankType> plankTypes,
    required int plankCount,
    required List<CustomPlankSet> customSets,
    required PlankSetDefinition officialSet,
    required List<PlankType> officialSetTypes,
    required Map<String, int> officialSetSeconds,
  }) async {
    if (_horizontalPage == _horizontalPlankPage) {
      final addPlankPageIndex = plankCount;
      if (_plankVerticalPage == addPlankPageIndex) {
        _openCustomPlankEditor();
        return;
      }

      final plank = plankTypes[_plankVerticalPage];
      final seconds = TargetSeconds.clamp(
        ref.read(targetSecondsProvider) ?? plank.defaultSeconds,
      );
      await _startPlank(plank, seconds);
      return;
    }

    if (_horizontalPage == _horizontalSetPage) {
      final addSetPageIndex = 1 + customSets.length;
      if (_setVerticalPage == addSetPageIndex) {
        _openCustomPlankSetEditor();
        return;
      }

      if (_setVerticalPage == 0) {
        await _startPlankSet(
          plankSet: officialSet,
          plankTypes: officialSetTypes,
          secondsByPlankId: officialSetSeconds,
        );
        return;
      }

      final customSet = customSets[_setVerticalPage - 1];
      final types = CustomPlankSetCarouselPanel.resolvePlankTypes(
        plankTypes,
        customSet,
      );
      await _startPlankSet(
        plankSet: customSet.toDefinition(),
        plankTypes: types,
        secondsByPlankId: _secondsForCustomSet(customSet),
      );
    }
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
                final setPageCount = 1 + customSets.length + 1;

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

                final isPlankSection = _horizontalPage == _horizontalPlankPage;
                final isSetSection = _horizontalPage == _horizontalSetPage;
                final isSelectionSection = isPlankSection || isSetSection;

                final isAddPlankPage =
                    isPlankSection && _plankVerticalPage == plankCount;
                final isAddSetPage =
                    isSetSection && _setVerticalPage == setPageCount - 1;

                final verticalPageCount =
                    isPlankSection ? plankCount + 1 : setPageCount;
                final verticalSelectedIndex =
                    isPlankSection ? _plankVerticalPage : _setVerticalPage;

                return Stack(
                  children: [
                    Row(
                      children: [
                        HomeNavArrowButton(
                          icon: Icons.chevron_left,
                          onPressed: _onPreviousHorizontal(),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _horizontalPageController,
                            physics: const ClampingScrollPhysics(),
                            onPageChanged: (page) {
                              setState(() => _horizontalPage = page);
                            },
                            children: [
                              CharacterPanel(
                                progressAsync: progressAsync,
                                streakAsync: streakAsync,
                              ),
                              PageView(
                                controller: _plankPageController,
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                onPageChanged: (page) =>
                                    _onPlankVerticalPageChanged(
                                  page,
                                  plankTypes,
                                ),
                                children: [
                                  for (var i = 0; i < plankTypes.length; i++)
                                    PlankDetailPanel(
                                      plank: plankTypes[i],
                                      targetSeconds: i == _plankVerticalPage
                                          ? targetSeconds
                                          : TargetSeconds.clamp(
                                              plankTypes[i].defaultSeconds,
                                            ),
                                      onTargetSecondsChanged: (seconds) {
                                        ref
                                            .read(
                                              targetSecondsProvider.notifier,
                                            )
                                            .state =
                                            TargetSeconds.clamp(seconds);
                                      },
                                      onEdit: CustomPlankTypeMapper
                                              .isCustomPlankTypeId(
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
                                ],
                              ),
                              PageView(
                                controller: _setPageController,
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                onPageChanged: (page) {
                                  setState(() => _setVerticalPage = page);
                                },
                                children: [
                                  PlankSetDetailPanel(
                                    setName: officialSet.name,
                                    plankTypes: officialSetTypes,
                                    targetSecondsByPlankId: officialSetSeconds,
                                    onTargetSecondsChanged: (plankId, seconds) {
                                      ref
                                          .read(
                                            plankSetTargetSecondsProvider
                                                .notifier,
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
                                      onTargetSecondsChanged:
                                          (plankId, seconds) {
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
                            ],
                          ),
                        ),
                        HomeNavArrowButton(
                          icon: Icons.chevron_right,
                          onPressed: _onNextHorizontal(),
                        ),
                      ],
                    ),
                    if (isSelectionSection) ...[
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            isPlankSection ? "種目を選ぶ" : "セットを選ぶ",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 48,
                        right: 48,
                        top: 44,
                        bottom: 120,
                        child: VerticalScrollHint(
                          currentIndex: verticalSelectedIndex,
                          pageCount: verticalPageCount,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton.icon(
                                    onPressed: () => _onStartPressed(
                                      plankTypes: plankTypes,
                                      plankCount: plankCount,
                                      customSets: customSets,
                                      officialSet: officialSet,
                                      officialSetTypes: officialSetTypes,
                                      officialSetSeconds: officialSetSeconds,
                                    ),
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
