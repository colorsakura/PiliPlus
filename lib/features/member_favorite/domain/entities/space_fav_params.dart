/// Parameters for fetching member favorite/subscribed collections
class MemberFavoriteParams {
  /// User ID
  final int mid;

  /// Page number (starts from 1)
  final int page;

  /// Page size (number of items per page)
  final int pageSize;

  const MemberFavoriteParams({
    required this.mid,
    required this.page,
    this.pageSize = 20,
  });

  /// Create next page parameters
  MemberFavoriteParams nextPage() {
    return MemberFavoriteParams(
      mid: mid,
      page: page + 1,
      pageSize: pageSize,
    );
  }

  @override
  String toString() => 'MemberFavoriteParams(mid: $mid, page: $page, pageSize: $pageSize)';
}

/// Parameters for fetching user favorite folders
class UserFavFolderParams extends MemberFavoriteParams {
  const UserFavFolderParams({
    required super.mid,
    required super.page,
    super.pageSize = 20,
  });
}

/// Parameters for fetching user subscription folders
class UserSubFolderParams extends MemberFavoriteParams {
  const UserSubFolderParams({
    required super.mid,
    required super.page,
    super.pageSize = 20,
  });
}
