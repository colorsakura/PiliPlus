import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/features/download/data/datasources/download_service_datasource.dart';
import 'package:PiliPlus/features/download/domain/entities/download_params.dart';
import 'package:PiliPlus/features/download/domain/repositories/download_repository.dart';

/// Implementation of download repository
class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadServiceDataSource serviceDataSource;

  const DownloadRepositoryImpl({
    required this.serviceDataSource,
  });

  @override
  Future<List<BiliDownloadEntryInfo>> fetchDownloadList(FetchDownloadListParams params) {
    return serviceDataSource.fetchDownloadList(params);
  }

  @override
  Future<void> cancelDownload(CancelDownloadParams params) {
    return serviceDataSource.cancelDownload(params);
  }

  @override
  Future<void> pauseDownload(PauseDownloadParams params) {
    // Pause is implemented as cancelDownload with isDelete: false
    return serviceDataSource.cancelDownload(CancelDownloadParams(
      isDelete: false,
      downloadNext: params.downloadNext,
    ));
  }

  @override
  Future<void> resumeDownload(ResumeDownloadParams params) {
    return serviceDataSource.startDownload(params.entry);
  }

  @override
  Future<void> deleteDownload(DeleteDownloadParams params) {
    return serviceDataSource.deleteDownload(params);
  }

  @override
  Future<void> deletePage(String pageDirPath) {
    return serviceDataSource.deletePage(pageDirPath);
  }
}
