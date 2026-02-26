import 'package:PiliPlus/models/common/member/contribute_type.dart';

/// Parameters for fetching member space archive (videos, seasons, series)
class FetchMemberArchiveParams {
  final int mid;
  final ContributeType type;
  final int? seasonId;
  final int? seriesId;
  final String? aid; // Video ID for pagination
  final String? order; // Order field (pubdate, click)
  final String? sort; // Sort direction (asc, desc)
  final int? page; // Page number for charging type
  final int? next; // Next cursor
  final bool includeCursor; // Include cursor for positioning

  const FetchMemberArchiveParams({
    required this.mid,
    required this.type,
    this.seasonId,
    this.seriesId,
    this.aid,
    this.order,
    this.sort,
    this.page,
    this.next,
    this.includeCursor = false,
  });
}

/// Result data for member archive fetch
class MemberArchiveResult {
  final List<dynamic>? items;
  final int? count;
  final int? next;
  final bool? hasPrev;
  final Map<String, dynamic>? episodicButton;

  const MemberArchiveResult({
    this.items,
    this.count,
    this.next,
    this.hasPrev,
    this.episodicButton,
  });
}
