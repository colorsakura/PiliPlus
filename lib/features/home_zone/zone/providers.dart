import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/home_zone/zone/controller_v2.dart';

/// Provider for ZoneControllerV2
///
/// Uses family to create separate instances for each zone (rid, seasonType)
final zoneControllerProvider = Provider.family<ZoneControllerV2, ({int? rid, int? seasonType})>(
  (ref, args) {
    final controller = ZoneControllerV2(
      rid: args.rid,
      seasonType: args.seasonType,
    );

    // Initialize data on first creation
    controller.onReload();

    // Dispose controller when provider is disposed
    ref.onDispose(controller.dispose);

    return controller;
  },
);
