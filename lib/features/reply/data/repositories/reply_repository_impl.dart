import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/models/reply2reply/data.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:PiliPlus/models/reply_interaction/data.dart';
import 'package:PiliPlus/features/reply/data/datasources/reply_remote_datasource.dart';
import 'package:PiliPlus/features/reply/domain/repositories/reply_repository.dart';

/// Reply repository implementation
class ReplyRepositoryImpl implements ReplyRepository {
  final ReplyRemoteDataSource remoteDataSource;

  const ReplyRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<ReplyData>> getReplyList({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  }) {
    return remoteDataSource.replyList(
      isLogin: isLogin,
      oid: oid,
      nextOffset: nextOffset,
      type: type,
      page: page,
      sort: sort,
    );
  }

  @override
  Future<LoadingState<ReplyReplyData>> getReplyReplyList({
    required bool isLogin,
    required int oid,
    required int root,
    required int pageNum,
    required int type,
    bool isCheck = false,
  }) {
    return remoteDataSource.replyReplyList(
      isLogin: isLogin,
      oid: oid,
      root: root,
      pageNum: pageNum,
      type: type,
      isCheck: isCheck,
    );
  }

  @override
  Future<LoadingState<Null>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) {
    return remoteDataSource.likeReply(
      type: type,
      oid: oid,
      rpid: rpid,
      action: action,
    );
  }

  @override
  Future<LoadingState<Null>> hateReply({
    required int type,
    required int action,
    required int oid,
    required int rpid,
  }) {
    return remoteDataSource.hateReply(
      type: type,
      action: action,
      oid: oid,
      rpid: rpid,
    );
  }

  @override
  Future<LoadingState<List<Package>?>> getEmoteList({
    String? business,
  }) {
    return remoteDataSource.getEmoteList(business: business);
  }

  @override
  Future<LoadingState<Null>> replyTop({
    required Object oid,
    required Object type,
    required Object rpid,
    required bool isUpTop,
  }) {
    return remoteDataSource.replyTop(
      oid: oid,
      type: type,
      rpid: rpid,
      isUpTop: isUpTop,
    );
  }

  @override
  Future<LoadingState<Null>> reportReply({
    required Object rpid,
    required Object oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  }) {
    return remoteDataSource.report(
      rpid: rpid,
      oid: oid,
      reasonType: reasonType,
      banUid: banUid,
      reasonDesc: reasonDesc,
    );
  }

  @override
  Future<LoadingState<ReplyInteractData>> getReplyInteraction({
    required Object oid,
    required Object type,
  }) {
    return remoteDataSource.replyInteraction(
      oid: oid,
      type: type,
    );
  }

  @override
  Future<LoadingState<Null>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  }) {
    return remoteDataSource.replySubjectModify(
      oid: oid,
      type: type,
      action: action,
    );
  }
}
