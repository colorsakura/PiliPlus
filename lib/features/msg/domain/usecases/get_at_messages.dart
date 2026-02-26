import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/features/msg/domain/repositories/msg_repository.dart';

/// Get at messages use case
class GetAtMessages {
  final MsgRepository repository;

  const GetAtMessages(this.repository);

  Future<LoadingState<MsgAtData>> call({
    int? cursor,
    int? cursorTime,
  }) {
    return repository.getAtMessages(
      cursor: cursor,
      cursorTime: cursorTime,
    );
  }
}
