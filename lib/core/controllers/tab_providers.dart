import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/controllers/simple_tab_controller.dart';

/// Provider family for SimpleTabControllerV2
final simpleTabControllerProvider =
    Provider.family<SimpleTabControllerV2?, _TabConfig>(
  (ref, config) {
    if (config.length <= 0) {
      return null;
    }
    final controller = SimpleTabControllerV2(
      length: config.length,
      vsync: config.vsync,
      initialIndex: config.initialIndex,
    );
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// Configuration for SimpleTabControllerV2
class _TabConfig {
  const _TabConfig({
    required this.length,
    required this.vsync,
    this.initialIndex = 0,
  });

  final int length;
  final TickerProvider vsync;
  final int initialIndex;
}
