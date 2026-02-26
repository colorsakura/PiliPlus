import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_like/data.dart';
import 'package:PiliPlus/features/msg/domain/repositories/msg_repository.dart';

/// Get like messages use case
class GetLikeMessages {
  final MsgRepository repository;

  const GetLikeMessages(this.repository);

  Future<LoadingState<MsgLikeData>> call({
    int? cursor,
    int? cursorTime,
  }) {
    return repository.getLikeMessages(
      cursor: cursor,
      cursorTime: cursorTime,
    );
  }
}
