import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/models/member_card_info/data.dart';

/// Repository for follow tags management
abstract class FollowRepository {
  /// Get user card info (for fetching user name)
  Future<LoadingState<MemberCardInfoData>> getMemberCardInfo(int mid);

  /// Get follow-up tags
  Future<LoadingState<List<MemberTagItemModel>>> getFollowUpTags();

  /// Create a new follow tag
  Future<LoadingState<void>> createFollowTag(String tagName);

  /// Update a follow tag name
  Future<LoadingState<void>> updateFollowTag(int tagId, String tagName);

  /// Delete a follow tag
  Future<LoadingState<void>> deleteFollowTag(int tagId);
}
