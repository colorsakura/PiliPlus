import 'package:PiliPlus/models/history/list.dart';

/// History search result entity
class HistorySearchResultEntity {
  final List<HistoryItemModel> historyItems;
  final bool hasMore;

  const HistorySearchResultEntity({
    this.historyItems = const [],
    this.hasMore = true,
  });
}

/// History search parameters entity
class HistorySearchParamsEntity {
  final String keyword;
  final int page;
  final int pageSize;
  final String account;

  const HistorySearchParamsEntity({
    required this.keyword,
    this.page = 1,
    this.pageSize = 20,
    required this.account,
  });

  HistorySearchParamsEntity copyWith({
    String? keyword,
    int? page,
    int? pageSize,
    String? account,
  }) {
    return HistorySearchParamsEntity(
      keyword: keyword ?? this.keyword,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      account: account ?? this.account,
    );
  }
}

/// History item delete parameters
class HistoryDeleteParamsEntity {
  final String historyKey; // format: "business_kid"
  final String account;

  const HistoryDeleteParamsEntity({
    required this.historyKey,
    required this.account,
  });
}
