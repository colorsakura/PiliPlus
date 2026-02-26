import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show SessionPageType;

/// Parameters for fetching secondary session list
class FetchSecondarySessionsParams {
  /// Session page type (e.g., SESSION_PAGE_TYPE_AT_ME, SESSION_PAGE_TYPE_LIKE_ME)
  final SessionPageType sessionPageType;

  /// Pagination offset
  final dynamic offset;

  const FetchSecondarySessionsParams({
    required this.sessionPageType,
    this.offset,
  });

  @override
  String toString() => 'FetchSecondarySessionsParams(sessionPageType: $sessionPageType)';
}

/// Entity representing secondary session list result
class SecondarySessionListResult {
  /// List of sessions
  final List sessions;

  /// Pagination offsets for next page
  final dynamic offsets;

  /// Whether there are more sessions to load
  final bool hasMore;

  /// Three-dot menu items
  final List threeDotItems;

  const SecondarySessionListResult({
    required this.sessions,
    required this.offsets,
    required this.hasMore,
    this.threeDotItems = const [],
  });

  @override
  String toString() => 'SecondarySessionListResult(sessions: ${sessions.length}, hasMore: $hasMore)';
}
