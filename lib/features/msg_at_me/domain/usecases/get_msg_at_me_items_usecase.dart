import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/features/msg_at_me/domain/repositories/msg_at_me_repository.dart';

/// Use case for fetching @Me notification items
class GetMsgAtMeItemsUseCase {
  const GetMsgAtMeItemsUseCase(this._repository);

  final MsgAtMeRepository _repository;

  /// Execute the use case
  Future<LoadingState<MsgAtData>> call({
    int? cursor,
    int? cursorTime,
  }) => _repository.getMsgAtMeItems(
    cursor: cursor,
    cursorTime: cursorTime,
  );
}
