import 'package:PiliPlus/features/msg_at_me/data/datasources/msg_at_me_remote_datasource.dart';
import 'package:PiliPlus/features/msg_at_me/domain/repositories/msg_at_me_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';

/// Repository implementation for @Me notifications
class MsgAtMeRepositoryImpl implements MsgAtMeRepository {
  const MsgAtMeRepositoryImpl(this._datasource);

  final MsgAtMeRemoteDatasource _datasource;

  @override
  Future<LoadingState<MsgAtData>> getMsgAtMeItems({
    int? cursor,
    int? cursorTime,
  }) => _datasource.getMsgAtMeItems(
    cursor: cursor,
    cursorTime: cursorTime,
  );

  @override
  Future<LoadingState<void>> removeMsgItem({
    required Object id,
  }) => _datasource.removeMsgItem(id: id);
}
