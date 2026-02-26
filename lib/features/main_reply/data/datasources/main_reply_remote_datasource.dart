import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart' show MainListReply;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/main_reply/domain/entities/main_reply_params.dart';

/// Data source interface for main reply operations
abstract class MainReplyRemoteDataSource {
  /// Fetch main reply list via gRPC API
  Future<LoadingState<MainListReply>> fetchMainReplies(FetchMainRepliesParams params);
}
