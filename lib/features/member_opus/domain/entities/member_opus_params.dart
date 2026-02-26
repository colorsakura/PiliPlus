/// Parameters for fetching member opus (图文 content) list
class FetchMemberOpusParams {
  final int hostMid;
  final int page;
  final String offset;
  final String type; // Filter type (e.g., "all" for all content)

  const FetchMemberOpusParams({
    required this.hostMid,
    required this.page,
    this.offset = '',
    this.type = 'all',
  });

  /// Create params for first page
  FetchMemberOpusParams copyWithFirstPage() {
    return FetchMemberOpusParams(
      hostMid: hostMid,
      page: 1,
      offset: '',
      type: type,
    );
  }
}
