import 'package:PiliPlus/models/common/fav_order_type.dart';

/// Favorite search result entity
class FavSearchResultEntity {
  final List<dynamic> medias;
  final bool hasMore;

  const FavSearchResultEntity({
    this.medias = const [],
    this.hasMore = true,
  });
}

/// Favorite search parameters entity
class FavSearchParamsEntity {
  final String keyword;
  final int mediaId;
  final int type;
  final FavOrderType order;
  final int page;
  final int pageSize;

  const FavSearchParamsEntity({
    required this.keyword,
    required this.mediaId,
    required this.type,
    required this.order,
    this.page = 1,
    this.pageSize = 20,
  });

  FavSearchParamsEntity copyWith({
    String? keyword,
    int? mediaId,
    int? type,
    FavOrderType? order,
    int? page,
    int? pageSize,
  }) {
    return FavSearchParamsEntity(
      keyword: keyword ?? this.keyword,
      mediaId: mediaId ?? this.mediaId,
      type: type ?? this.type,
      order: order ?? this.order,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
