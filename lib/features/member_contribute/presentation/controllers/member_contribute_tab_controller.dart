import 'dart:math';
import 'package:flutter/material.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';

/// Member Contribute Tab Controller V2 - Riverpod compatible
///
/// Manages tabs for user contributed content
class MemberContributeTabControllerV2 extends ChangeNotifier {
  MemberContributeTabControllerV2({
    required this.items,
    required this.hasSeasonOrSeries,
    TickerProvider? vsync,
    int initialIndex = 0,
  }) {
    _initializeTabs(initialIndex, vsync);
  }

  final List<SpaceTab2Item> items;
  final bool hasSeasonOrSeries;
  TabController? _tabController;
  List<Tab>? _tabs;

  TabController? get tabController => _tabController;
  List<Tab>? get tabs => _tabs;

  void _initializeTabs(int initialIndex, TickerProvider? vsync) {
    if (items.isEmpty) {
      return;
    }

    final displayItems = List<SpaceTab2Item>.from(items);

    // Add "全部合集/列表" tab if user has season or series
    if (items.length > 1 && hasSeasonOrSeries) {
      displayItems.add(
        const SpaceTab2Item(
          param: 'ugcSeason',
          title: '全部合集/列表',
        ),
      );
    }

    if (displayItems.length > 1) {
      _tabs = displayItems.map((item) => Tab(text: item.title)).toList();
      if (vsync != null) {
        _tabController = TabController(
          vsync: vsync,
          length: displayItems.length,
          initialIndex: max(0, initialIndex),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
