import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/download/domain/entities/download_params.dart';

/// Repository interface for download operations
abstract class DownloadRepository {
  /// Fetch download list
  Future<List<BiliDownloadEntryInfo>> fetchDownloadList(FetchDownloadListParams params);

  /// Cancel download (with isDelete flag for pause vs cancel)
  Future<void> cancelDownload(CancelDownloadParams params);

  /// Pause download (alias for cancelDownload with isDelete: false)
  Future<void> pauseDownload(PauseDownloadParams params);

  /// Resume/start download
  Future<void> resumeDownload(ResumeDownloadParams params);

  /// Delete download entry
  Future<void> deleteDownload(DeleteDownloadParams params);

  /// Delete download page directory
  Future<void> deletePage(String pageDirPath);
}
