import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Entity representing parameters for sorting favorite folders
class FavFolderSortParams {
  /// Ordered list of folder IDs
  final List<int> folderIds;

  const FavFolderSortParams({
    required this.folderIds,
  });

  /// Create sort string from folder IDs (comma-separated)
  String get sortString => folderIds.join(',');

  /// Create from list of FavFolderInfo
  factory FavFolderSortParams.fromFolderList(List<FavFolderInfo> folders) {
    return FavFolderSortParams(
      folderIds: folders.map((e) => e.id).toList(),
    );
  }

  /// Create new params with reordered list
  FavFolderSortParams withReorderedList(List<FavFolderInfo> reorderedFolders) {
    return FavFolderSortParams.fromFolderList(reorderedFolders);
  }

  @override
  String toString() => 'FavFolderSortParams(folderIds: $folderIds)';
}

/// Entity representing the result of a folder sort operation
class FavFolderSortResult {
  /// Whether the sort was successful
  final bool isSuccess;

  /// Error message if sort failed
  final String? errorMessage;

  const FavFolderSortResult({
    required this.isSuccess,
    this.errorMessage,
  });

  /// Create a success result
  factory FavFolderSortResult.success() {
    return const FavFolderSortResult(isSuccess: true);
  }

  /// Create an error result
  factory FavFolderSortResult.error(String errorMessage) {
    return FavFolderSortResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
