import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';
import 'package:PiliPlus/features/member_contribute/presentation/providers/member_contribute_state.dart';

part 'member_contribute_controller_v2.g.dart';

/// Controller for member contribute page (Riverpod version)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)
@riverpod
class MemberContributeController extends _$MemberContributeController {
  @override
  MemberContributeState build(
    SpaceTab2 contributeTab,
    bool hasSeasonOrSeries,
    int? initialIndex,
  ) {
    return _initializeTabs(contributeTab, hasSeasonOrSeries, initialIndex);
  }

  MemberContributeState _initializeTabs(
    SpaceTab2 contributeTab,
    bool hasSeasonOrSeries,
    int? initialIndex,
  ) {
    final items = contributeTab.items;
    if (items == null || items.isEmpty || items.length <= 1) {
      // No tabs needed for single item or no items
      return MemberContributeState(items: items ?? []);
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

    return MemberContributeState(items: tabItems, tabs: tabs);
  }
}
