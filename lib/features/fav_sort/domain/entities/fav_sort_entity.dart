import 'package:PiliPlus/models/fav/fav_detail/media.dart';

/// Entity representing a sort operation for favorite items
class FavSortEntity {
  /// The media ID of the favorite folder
  final Object mediaId;

  /// The sort string in format "prevItemId:prevItemType:currItemId:currItemType"
  final String sort;

  const FavSortEntity({
    required this.mediaId,
    required this.sort,
  });

  /// Create a sort entry string from two items
  static String createSortEntry(FavDetailItemModel? prevItem, FavDetailItemModel currItem) {
    final prevStr = prevItem == null
        ? '0:0'
        : '${prevItem.id}:${prevItem.type}';
    return '$prevStr:${currItem.id}:${currItem.type}';
  }

  @override
  String toString() => 'FavSortEntity(mediaId: $mediaId, sort: $sort)';
}
