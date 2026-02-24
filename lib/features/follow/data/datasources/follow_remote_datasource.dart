import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/models/member_card_info/data.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Remote datasource for follow tags
class FollowRemoteDatasource implements FollowRepository {
  const FollowRemoteDatasource();

  @override
  Future<LoadingState<MemberCardInfoData>> getMemberCardInfo(int mid) =>
      MemberHttp.memberCardInfo(mid: mid);

  @override
  Future<LoadingState<List<MemberTagItemModel>>> getFollowUpTags() =>
      MemberHttp.followUpTags();

  @override
  Future<LoadingState<void>> createFollowTag(String tagName) =>
      MemberHttp.createFollowTag(tagName);

  @override
  Future<LoadingState<void>> updateFollowTag(int tagId, String tagName) =>
      MemberHttp.updateFollowTag(tagId, tagName);

  @override
  Future<LoadingState<void>> deleteFollowTag(int tagId) =>
      MemberHttp.delFollowTag(tagId);
}
