import 'package:flutter/foundation.dart';

import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/download/domain/entities/download_params.dart';

/// Data source interface for download service operations
abstract class DownloadServiceDataSource {
  /// Fetch download list from download service
  Future<List<BiliDownloadEntryInfo>> fetchDownloadList(FetchDownloadListParams params);

  /// Wait for download service initialization
  Future<void> waitForInitialization();

  /// Cancel download via download service (with isDelete flag for pause vs cancel)
  Future<void> cancelDownload(CancelDownloadParams params);

  /// Start/resume download via download service
  Future<void> startDownload(BiliDownloadEntryInfo entry);

  /// Delete download entry via download service
  Future<void> deleteDownload(DeleteDownloadParams params);

  /// Delete download page directory via download service
  Future<void> deletePage(String pageDirPath);

  /// Get flag notifier for change notifications
  Set<VoidCallback> get flagNotifier;
}
