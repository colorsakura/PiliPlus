import 'package:PiliPlus/features/pgc_index/domain/entities/pgc_index_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';

/// PGC索引仓库接口
abstract interface class PgcIndexRepository {
  /// 获取PGC索引条件
  Future<LoadingState<PgcIndexConditionData>> getPgcIndexCondition({
    int? indexType,
  });

  /// 获取PGC索引结果
  Future<LoadingState<PgcIndexResultEntity>> getPgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    int? indexType,
  });
}
