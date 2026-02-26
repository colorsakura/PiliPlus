import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/domain/entities/search_result_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';

/// 分类搜索用例
class SearchByTypeUseCase {
  final SearchRepository _repository;

  const SearchByTypeUseCase(this._repository);

  /// 执行分类搜索
  ///
  /// [searchType] 搜索类型
  /// [keyword] 搜索关键词
  /// [page] 页码
  /// [order] 排序方式
  /// [duration] 时长筛选
  /// [tids] 分区ID
  /// [orderSort] 排序类型
  /// [userType] 用户类型
  /// [categoryId] 分类ID
  /// [pubBegin] 发布开始时间
  /// [pubEnd] 发布结束时间
  /// [gaiaVtoken] 验证token
  /// 返回搜索结果状态
  Future<LoadingState<List<SearchResultEntity>>> call({
    required SearchType searchType,
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
    String? gaiaVtoken,
  }) async {
    try {
      final result = await _repository.searchByType(
        searchType: searchType,
        keyword: keyword,
        page: page,
        order: order,
        duration: duration,
        tids: tids,
        orderSort: orderSort,
        userType: userType,
        categoryId: categoryId,
        pubBegin: pubBegin,
        pubEnd: pubEnd,
        gaiaVtoken: gaiaVtoken,
      );
      return Success(result);
    } on ServerFailure catch (e) {
      return Error(e.message);
    } on NetworkFailure catch (e) {
      return Error(e.message);
    }
  }
}
