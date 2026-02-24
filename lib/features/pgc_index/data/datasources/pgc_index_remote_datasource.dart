import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/pgc.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';

/// PGC索引远程数据源
class PgcIndexRemoteDataSource {
  /// 获取PGC索引条件
  Future<LoadingState<PgcIndexConditionData>> getPgcIndexCondition({
    int? indexType,
  }) {
    return PgcHttp.pgcIndexCondition(
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
  }

  /// 获取PGC索引结果
  Future<LoadingState<dynamic>> getPgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    int? indexType,
  }) {
    return PgcHttp.pgcIndexResult(
      page: page,
      params: params,
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
  }
}
