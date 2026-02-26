import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/download/domain/entities/download_params.dart';
import 'package:PiliPlus/features/download/domain/repositories/download_repository.dart';

/// Use case for fetching download list
class FetchDownloadList {
  final DownloadRepository repository;

  const FetchDownloadList(this.repository);

  Future<Map<String, List<BiliDownloadEntryInfo>>> call(FetchDownloadListParams params) async {
    final list = await repository.fetchDownloadList(params);
    // Group entries by pageId for the UI
    final grouped = <String, List<BiliDownloadEntryInfo>>{};
    for (final entry in list) {
      final pageId = entry.pageId;
      grouped.putIfAbsent(pageId, () => []).add(entry);
    }
    return grouped;
  }
}

/// Use case for canceling download
class CancelDownload {
  final DownloadRepository repository;

  const CancelDownload(this.repository);

  Future<void> call(CancelDownloadParams params) =>
      repository.cancelDownload(params);
}

/// Use case for pausing download
class PauseDownload {
  final DownloadRepository repository;

  const PauseDownload(this.repository);

  Future<void> call(PauseDownloadParams params) =>
      repository.pauseDownload(params);
}

/// Use case for resuming download
class ResumeDownload {
  final DownloadRepository repository;

  const ResumeDownload(this.repository);

  Future<void> call(ResumeDownloadParams params) =>
      repository.resumeDownload(params);
}

/// Use case for deleting download
class DeleteDownload {
  final DownloadRepository repository;

  const DeleteDownload(this.repository);

  Future<void> call(DeleteDownloadParams params) =>
      repository.deleteDownload(params);
}

/// Use case for deleting download page
class DeleteDownloadPage {
  final DownloadRepository repository;

  const DeleteDownloadPage(this.repository);

  Future<void> call(String pageDirPath) =>
      repository.deletePage(pageDirPath);
}
