import 'package:PiliPlus/models/common/live/live_search_type.dart';

/// Parameters for live search
class LiveSearchParams {
  /// Search keyword
  final String keyword;

  /// Search type (room or user)
  final LiveSearchType type;

  /// Page number (starts from 1)
  final int page;

  const LiveSearchParams({
    required this.keyword,
    required this.type,
    required this.page,
  });

  /// Create next page parameters
  LiveSearchParams nextPage() {
    return LiveSearchParams(
      keyword: keyword,
      type: type,
      page: page + 1,
    );
  }

  /// Check if this is room search
  bool get isRoomSearch => type == LiveSearchType.room;

  /// Check if this is user search
  bool get isUserSearch => type == LiveSearchType.user;

  @override
  String toString() => 'LiveSearchParams(keyword: $keyword, type: $type, page: $page)';
}
