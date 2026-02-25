import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/download/presentation/controllers/download_multi_select_controller.dart';

/// Provider for DownloadMultiSelectControllerV2
final downloadMultiSelectControllerProvider =
    Provider<DownloadMultiSelectControllerV2>((ref) {
  final controller = DownloadMultiSelectControllerV2();
  ref.onDispose(controller.dispose);
  return controller;
});
