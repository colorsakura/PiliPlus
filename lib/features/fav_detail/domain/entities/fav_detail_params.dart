import 'package:PiliPlus/models/common/fav_order_type.dart';

/// Parameters for fetching favorite folder detail
class FetchFavDetailParams {
  final int mediaId;
  final int page;
  final int pageSize;
  final FavOrderType order;

  const FetchFavDetailParams({
    required this.mediaId,
    required this.page,
    this.pageSize = 20,
    required this.order,
  });
}

/// Parameters for canceling favorites
class CancelFavoriteParams {
  final String resources; // Format: "id:type"
  final int mediaId;

  const CancelFavoriteParams({
    required this.resources,
    required this.mediaId,
  });

  /// Create resources string from list of items
  static String fromList(List<({int id, int type})> items) {
    return items.map((e) => '${e.id}:${e.type}').join(',');
  }
}

/// Parameters for favoriting/unfavoriting a folder
class ToggleFavFolderParams {
  final int mediaId;
  final bool isFavorite;

  const ToggleFavFolderParams({
    required this.mediaId,
    required this.isFavorite,
  });
}

/// Parameters for cleaning favorites
class CleanFavoritesParams {
  final int mediaId;

  const CleanFavoritesParams({
    required this.mediaId,
  });
}
