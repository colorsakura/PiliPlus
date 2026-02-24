import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/models/member_card_info/data.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';
import 'package:PiliPlus/features/follow/data/datasources/follow_remote_datasource.dart';

/// Repository implementation for follow tags
class FollowRepositoryImpl implements FollowRepository {
  const FollowRepositoryImpl(this._remoteDatasource);

  final FollowRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<MemberCardInfoData>> getMemberCardInfo(int mid) =>
      _remoteDatasource.getMemberCardInfo(mid);

  @override
  Future<LoadingState<List<MemberTagItemModel>>> getFollowUpTags() =>
      _remoteDatasource.getFollowUpTags();

  @override
  Future<LoadingState<void>> createFollowTag(String tagName) =>
      _remoteDatasource.createFollowTag(tagName);

  @override
  Future<LoadingState<void>> updateFollowTag(int tagId, String tagName) =>
      _remoteDatasource.updateFollowTag(tagId, tagName);

  @override
  Future<LoadingState<void>> deleteFollowTag(int tagId) =>
      _remoteDatasource.deleteFollowTag(tagId);
}
