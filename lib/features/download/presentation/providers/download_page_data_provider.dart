import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/features/download/presentation/controllers/download_page_data_controller.dart';
import 'package:PiliPlus/services/download/download_service.dart';

/// Provider for DownloadService
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return Get.find<DownloadService>();
});

/// Provider for DownloadPageDataControllerV2
final downloadPageDataControllerProvider =
    Provider<DownloadPageDataControllerV2>((ref) {
      final downloadService = ref.watch(downloadServiceProvider);
      final controller = DownloadPageDataControllerV2(downloadService);
      controller.init();
      ref.onDispose(controller.dispose);
      return controller;
    });
