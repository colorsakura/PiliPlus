import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/data/datasources/danmaku_filter_api_datasource.dart';

/// Remote data source for danmaku block rules
class DanmakuBlockRemoteDatasource {
  final _dataSource = DanmakuFilterRemoteDataSource();

  DanmakuBlockRemoteDatasource();

  /// Fetch all danmaku block rules via API
  Future<LoadingState<DanmakuBlockDataModel>> getDanmakuFilterRules() async {
    try {
      final result = await _dataSource.danmakuFilter();
      return Success(DanmakuBlockDataModel.fromJson(result));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Delete a danmaku block rule via API
  Future<LoadingState<void>> deleteRule(int id) async {
    try {
      await _dataSource.danmakuFilterDel(ids: id);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Add a new danmaku block rule via API
  Future<LoadingState<SimpleRule>> addRule({
    required String filter,
    required int type,
  }) async {
    try {
      final result = await _dataSource.danmakuFilterAdd(
        filter: filter,
        type: type,
      );
      return Success(SimpleRule.fromJson(result));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
