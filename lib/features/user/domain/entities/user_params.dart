/// Parameters for fetching user information
class FetchUserInfoParams {
  final bool forceRefresh;

  const FetchUserInfoParams({
    this.forceRefresh = false,
  });
}

/// Parameters for fetching user statistics
class FetchUserStatParams {
  final bool isOwner;

  const FetchUserStatParams({
    required this.isOwner,
  });
}

/// Parameters for fetching "See You Later" (watch later) list
class FetchSeeYouLaterParams {
  final int page;
  final int viewed; // 0=not viewed, 1=viewed
  final String keyword;
  final bool asc;

  const FetchSeeYouLaterParams({
    required this.page,
    this.viewed = 0,
    this.keyword = '',
    this.asc = false,
  });
}
