import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/share/data/datasources/share_remote_datasource.dart';
import 'package:PiliPlus/features/share/domain/entities/share_user.dart';
import 'package:PiliPlus/features/share/domain/repositories/share_repository.dart';

/// Share repository implementation
class ShareRepositoryImpl implements ShareRepository {
  final ShareRemoteDataSource remoteDataSource;

  const ShareRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Map<int, bool>>> sendShare({
    required List<ShareUserEntity> users,
    required Map content,
    String? message,
  }) async {
    final results = <int, bool>{};

    try {
      for (final user in users) {
        final success = await remoteDataSource.sendShareMessage(
          receiverId: user.mid,
          content: content,
          message: message,
        );
        results[user.mid] = success;
      }
      return Success(results);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
