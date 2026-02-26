import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/danmaku_filter/data/datasources/danmaku_filter_remote_datasource.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/entities/danmaku_filter_entity.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/repositories/danmaku_filter_repository.dart';

/// Danmaku filter repository implementation
class DanmakuFilterRepositoryImpl implements DanmakuFilterRepository {
  final DanmakuFilterRemoteDataSource remoteDataSource;

  const DanmakuFilterRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<DanmakuFilterEntity>> getDanmakuFilter() async {
    try {
      final dataModel = await remoteDataSource.danmakuFilter();
      final entity = DanmakuFilterEntity.fromModel(dataModel);
      return Success(entity);
    } on ServerException catch (e) {
      return Error(e.message ?? '获取弹幕过滤规则失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<FilterRule>> addFilterRule({
    required String filter,
    required FilterRuleType type,
  }) async {
    try {
      final simpleRule = await remoteDataSource.danmakuFilterAdd(
        filter: filter,
        type: type.value,
      );
      final rule = FilterRule.fromSimpleRule(simpleRule, type);
      return Success(rule);
    } on ServerException catch (e) {
      return Error(e.message ?? '添加弹幕过滤规则失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<void>> deleteFilterRule({
    required int id,
  }) async {
    try {
      await remoteDataSource.danmakuFilterDel(ids: id);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(e.message ?? '删除弹幕过滤规则失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
