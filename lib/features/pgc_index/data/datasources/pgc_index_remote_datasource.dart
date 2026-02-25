import 'package:PiliPlus/features/pgc/data/datasources/pgc_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';

/// PGC索引远程数据源
class PgcIndexRemoteDataSource {
  final _pgcApiDataSource = PgcApiDataSource();

  /// 获取PGC索引条件
  Future<LoadingState<PgcIndexConditionData>> getPgcIndexCondition({
    int? indexType,
  }) async {
    final result = await _pgcApiDataSource.getPgcIndexCondition(
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );

    return switch (result) {
      Loading() => result,
      Success(:final response) => Success(PgcIndexConditionData.fromJson(response)),
      Error() => result,
    };
  }

  /// 获取PGC索引结果
  Future<LoadingState<dynamic>> getPgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    int? indexType,
  }) {
    return _pgcApiDataSource.getPgcIndexResult(
      page: page,
      params: params,
      seasonType: indexType == null ? 1 : null,
      type: 0,
      indexType: indexType,
    );
  }
}
