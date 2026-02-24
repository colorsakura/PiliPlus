import 'dart:math';

import 'package:flutter/material.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';
import 'package:PiliPlus/features/member_contribute/presentation/providers/member_contribute_state.dart';

/// Controller for member contribute page (Clean Architecture with Riverpod)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)
class MemberContributeController extends ChangeNotifier {
  MemberContributeController({
    required this.contributeTab,
    required this.hasSeasonOrSeries,
    required int? initialIndex,
  })  : _state = MemberContributeState(items: contributeTab.items ?? []) {
    _initializeTabs(initialIndex);
  }

  final SpaceTab2 contributeTab;
  final bool hasSeasonOrSeries;
  TabController? tabController;

  MemberContributeState _state;
  MemberContributeState get state => _state;

  void _initializeTabs(int? initialIndex) {
    final items = contributeTab.items;
    if (items == null || items.isEmpty || items.length <= 1) {
      // No tabs needed for single item or no items
      return;
    }

    // Build items list
    final List<SpaceTab2Item> tabItems = List.from(items);

    // Add ugcSeason item if exists
    if (hasSeasonOrSeries) {
      tabItems.add(
        const SpaceTab2Item(
          param: 'ugcSeason',
          title: '全部合集/列表',
        ),
      );
    }

    // Create tabs
    final tabs = tabItems.map((item) => Tab(text: item.title)).toList();

    _state = _state.copyWith(items: tabItems, tabs: tabs);

    // Note: TabController requires TickerProvider which isn't available here
    // The page will need to initialize it lazily
  }

  /// Initialize TabController (must be called with TickerProvider)
  void initTabController(TickerProvider vsync, int? initialIndex) {
    if (_state.tabs != null && _state.tabs!.length > 1) {
      tabController = TabController(
        vsync: vsync,
        length: _state.tabs!.length,
        initialIndex: max(0, initialIndex ?? 0),
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
