import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/history/presentation/controllers/history_multi_select_controller.dart';

/// Provider for HistoryMultiSelectControllerV2
final historyMultiSelectControllerProvider =
    Provider<HistoryMultiSelectControllerV2>((ref) {
      final controller = HistoryMultiSelectControllerV2();
      ref.onDispose(controller.dispose);
      return controller;
    });
