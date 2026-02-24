import 'package:PiliPlus/features/pgc_index/domain/entities/pgc_index_item.dart';
import 'package:PiliPlus/features/pgc_index/domain/repositories/pgc_index_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';

/// 获取PGC索引条件用例
class GetPgcIndexConditionUseCase {
  final PgcIndexRepository _repository;

  const GetPgcIndexConditionUseCase(this._repository);

  Future<LoadingState<PgcIndexConditionData>> call({int? indexType}) {
    return _repository.getPgcIndexCondition(indexType: indexType);
  }
}

/// 获取PGC索引结果用例
class GetPgcIndexResultUseCase {
  final PgcIndexRepository _repository;

  const GetPgcIndexResultUseCase(this._repository);

  Future<LoadingState<List<PgcIndexItemEntity>?>> call({
    required int page,
    required Map<String, dynamic> params,
    int? indexType,
  }) async {
    final result = await _repository.getPgcIndexResult(
      page: page,
      params: params,
      indexType: indexType,
    );

    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.items),
      Error() => result as LoadingState<List<PgcIndexItemEntity>?>,
    };
  }
}
