import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_contribute/presentation/controllers/member_contribute_tab_controller.dart';

/// Provider family for MemberContributeTabControllerV2
final memberContributeTabControllerProvider =
    Provider.family<MemberContributeTabControllerV2?, _ContributeTabConfig>(
  (ref, config) {
    if (config.items.isEmpty) {
      return null;
    }
    final controller = MemberContributeTabControllerV2(
      items: config.items,
      hasSeasonOrSeries: config.hasSeasonOrSeries,
      vsync: config.vsync,
      initialIndex: config.initialIndex,
    );
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// Configuration for MemberContributeTabControllerV2
class _ContributeTabConfig {
  const _ContributeTabConfig({
    required this.items,
    required this.hasSeasonOrSeries,
    required this.vsync,
    this.initialIndex = 0,
  });

  final List items;
  final bool hasSeasonOrSeries;
  final TickerProvider vsync;
  final int initialIndex;
}
