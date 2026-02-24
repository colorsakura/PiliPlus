import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/domain/repositories/danmaku_block_repository.dart';
import 'package:PiliPlus/features/danmaku_block/data/datasources/danmaku_block_remote_datasource.dart';

/// Repository implementation for danmaku block rules
class DanmakuBlockRepositoryImpl implements DanmakuBlockRepository {
  const DanmakuBlockRepositoryImpl(this._remoteDatasource);

  final DanmakuBlockRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<DanmakuBlockDataModel>> getDanmakuFilterRules() {
    return _remoteDatasource.getDanmakuFilterRules();
  }

  @override
  Future<LoadingState<void>> deleteRule(int id) {
    return _remoteDatasource.deleteRule(id);
  }

  @override
  Future<LoadingState<SimpleRule>> addRule({
    required String filter,
    required int type,
  }) {
    return _remoteDatasource.addRule(filter: filter, type: type);
  }
}
