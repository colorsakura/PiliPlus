import 'package:PiliPlus/models/download/bili_download_entry_info.dart';

/// Parameters for fetching download list
class FetchDownloadListParams {
  final bool forceRefresh;

  const FetchDownloadListParams({
    this.forceRefresh = false,
  });
}

/// Parameters for canceling download
class CancelDownloadParams {
  final bool isDelete;
  final bool? downloadNext;

  const CancelDownloadParams({
    this.isDelete = false,
    this.downloadNext,
  });
}

/// Parameters for pausing download
class PauseDownloadParams {
  final bool? downloadNext;

  const PauseDownloadParams({
    this.downloadNext,
  });
}

/// Parameters for resuming download
class ResumeDownloadParams {
  final BiliDownloadEntryInfo entry;

  const ResumeDownloadParams({
    required this.entry,
  });
}

/// Parameters for deleting download
class DeleteDownloadParams {
  final BiliDownloadEntryInfo entry;
  final bool? removeList;
  final bool? removeQueue;
  final bool? refresh;
  final bool? downloadNext;

  const DeleteDownloadParams({
    required this.entry,
    this.removeList,
    this.removeQueue,
    this.refresh,
    this.downloadNext,
  });
}
