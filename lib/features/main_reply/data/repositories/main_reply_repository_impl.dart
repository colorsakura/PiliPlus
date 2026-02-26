import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart' show MainListReply;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/main_reply/data/datasources/main_reply_remote_datasource.dart';
import 'package:PiliPlus/features/main_reply/domain/entities/main_reply_params.dart';
import 'package:PiliPlus/features/main_reply/domain/repositories/main_reply_repository.dart';

/// Implementation of main reply repository
class MainReplyRepositoryImpl implements MainReplyRepository {
  final MainReplyRemoteDataSource remoteDataSource;

  const MainReplyRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<MainListReply>> fetchMainReplies(FetchMainRepliesParams params) {
    return remoteDataSource.fetchMainReplies(params);
  }
}
