import 'package:PiliPlus/models/common/reply/reply_search_type.dart';

/// Reply search parameters entity
class ReplySearchParamsEntity {
  final int type;
  final int oid;
  final String keyword;
  final ReplySearchType searchType;
  final int page;

  const ReplySearchParamsEntity({
    required this.type,
    required this.oid,
    required this.keyword,
    required this.searchType,
    required this.page,
  });

  /// Create copy with modified fields
  ReplySearchParamsEntity copyWith({
    int? type,
    int? oid,
    String? keyword,
    ReplySearchType? searchType,
    int? page,
  }) {
    return ReplySearchParamsEntity(
      type: type ?? this.type,
      oid: oid ?? this.oid,
      keyword: keyword ?? this.keyword,
      searchType: searchType ?? this.searchType,
      page: page ?? this.page,
    );
  }

  /// Create params for next page
  ReplySearchParamsEntity nextPage() {
    return copyWith(page: page + 1);
  }

  @override
  String toString() =>
      'ReplySearchParamsEntity(type: $type, oid: $oid, keyword: $keyword, searchType: $searchType, page: $page)';
}
