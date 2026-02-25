import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/download/presentation/controllers/download_page_data_controller.dart';
import 'package:PiliPlus/services/service_locator.dart';

/// Provider for DownloadPageDataControllerV2
final downloadPageDataControllerProvider =
    Provider<DownloadPageDataControllerV2>((ref) {
  final downloadService = getIt<DownloadService>();
  final controller = DownloadPageDataControllerV2(downloadService);
  controller.init();
  ref.onDispose(controller.dispose);
  return controller;
});
