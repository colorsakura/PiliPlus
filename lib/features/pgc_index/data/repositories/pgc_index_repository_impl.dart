import 'package:PiliPlus/features/pgc_index/data/datasources/pgc_index_remote_datasource.dart';
import 'package:PiliPlus/features/pgc_index/domain/entities/pgc_index_item.dart';
import 'package:PiliPlus/features/pgc_index/domain/repositories/pgc_index_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/data.dart';

/// PGC索引仓库实现
class PgcIndexRepositoryImpl implements PgcIndexRepository {
  final PgcIndexRemoteDataSource _remoteDataSource;

  PgcIndexRepositoryImpl({
    required PgcIndexRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<PgcIndexConditionData>> getPgcIndexCondition({
    int? indexType,
  }) {
    return _remoteDataSource.getPgcIndexCondition(indexType: indexType);
  }

  @override
  Future<LoadingState<PgcIndexResultEntity>> getPgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    int? indexType,
  }) async {
    final result = await _remoteDataSource.getPgcIndexResult(
      page: page,
      params: params,
      indexType: indexType,
    );

    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(
          _convertToEntity(response as PgcIndexResult),
        ),
      Error() => result as LoadingState<PgcIndexResultEntity>,
    };
  }

  PgcIndexResultEntity _convertToEntity(PgcIndexResult response) {
    return PgcIndexResultEntity(
      items: response.list?.map((e) => PgcIndexItemEntity.fromModel(e)).toList(),
      hasNext: (response.hasNext ?? 0) != 0,
    );
  }
}
