import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart' show MainListReply;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/main_reply/data/datasources/main_reply_remote_datasource.dart';
import 'package:PiliPlus/features/main_reply/domain/entities/main_reply_params.dart';

/// Implementation of main reply remote data source using gRPC
class MainReplyRemoteDataSourceImpl implements MainReplyRemoteDataSource {
  const MainReplyRemoteDataSourceImpl();

  @override
  Future<LoadingState<MainListReply>> fetchMainReplies(FetchMainRepliesParams params) {
    return ReplyGrpc.mainList(
      type: params.replyType,
      oid: params.oid,
      mode: params.mode,
      cursorNext: params.cursorNext,
      offset: params.paginationReply?['nextOffset'],
    );
  }
}
