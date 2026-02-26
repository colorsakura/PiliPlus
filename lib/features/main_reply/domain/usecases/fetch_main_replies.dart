import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart' show MainListReply;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/main_reply/domain/entities/main_reply_params.dart';
import 'package:PiliPlus/features/main_reply/domain/repositories/main_reply_repository.dart';

/// Use case for fetching main reply list
class FetchMainReplies {
  final MainReplyRepository repository;

  const FetchMainReplies(this.repository);

  Future<LoadingState<MainListReply>> call(FetchMainRepliesParams params) =>
      repository.fetchMainReplies(params);
}
