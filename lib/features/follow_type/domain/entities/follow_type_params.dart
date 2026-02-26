/// Parameters for fetching follow list
class FollowTypeParams {
  /// User ID to fetch follows for
  final int mid;

  /// Page number
  final int page;

  const FollowTypeParams({
    required this.mid,
    required this.page,
  });

  /// Create next page parameters
  FollowTypeParams nextPage() {
    return FollowTypeParams(
      mid: mid,
      page: page + 1,
    );
  }

  @override
  String toString() => 'FollowTypeParams(mid: $mid, page: $page)';
}

/// Parameters for fetching followers (users who follow the specified user)
class FollowedParams extends FollowTypeParams {
  const FollowedParams({
    required super.mid,
    required super.page,
  });
}

/// Parameters for fetching mutual follows (users with same follows)
class FollowSameParams extends FollowTypeParams {
  const FollowSameParams({
    required super.mid,
    required super.page,
  });
}
