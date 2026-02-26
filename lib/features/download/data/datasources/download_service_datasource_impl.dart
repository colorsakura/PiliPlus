import 'package:flutter/foundation.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/download/data/datasources/download_service_datasource.dart';
import 'package:PiliPlus/features/download/domain/entities/download_params.dart';
import 'package:get/get.dart';

/// Implementation wrapping DownloadService as a data source
class DownloadServiceDataSourceImpl implements DownloadServiceDataSource {
  DownloadServiceDataSourceImpl() : _downloadService = Get.find<DownloadService>();

  final DownloadService _downloadService;

  @override
  Future<List<BiliDownloadEntryInfo>> fetchDownloadList(FetchDownloadListParams params) async {
    // Wait for initialization to complete
    await _downloadService.waitForInitialization;
    // Return the download list (completed downloads)
    return _downloadService.downloadList;
  }

  @override
  Future<void> waitForInitialization() => _downloadService.waitForInitialization;

  @override
  Future<void> cancelDownload(CancelDownloadParams params) async {
    await _downloadService.cancelDownload(
      isDelete: params.isDelete,
      downloadNext: params.downloadNext ?? true,
    );
  }

  @override
  Future<void> startDownload(BiliDownloadEntryInfo entry) async {
    await _downloadService.startDownload(entry);
  }

  @override
  Future<void> deleteDownload(DeleteDownloadParams params) async {
    await _downloadService.deleteDownload(
      entry: params.entry,
      removeList: params.removeList ?? true,
      removeQueue: params.removeQueue ?? false,
      refresh: params.refresh ?? true,
      downloadNext: params.downloadNext ?? true,
    );
  }

  @override
  Future<void> deletePage(String pageDirPath) async {
    await _downloadService.deletePage(
      pageDirPath: pageDirPath,
      refresh: true,
    );
  }

  @override
  Set<VoidCallback> get flagNotifier => _downloadService.flagNotifier;
}
