import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/domain/entities/search_history_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_result_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_suggest_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_trending_entity.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';

/// 搜索仓库接口
///
/// 定义所有搜索相关操作的抽象
abstract class SearchRepository {
  /// 获取搜索建议
  ///
  /// [term] 搜索关键词
  /// 返回搜索建议列表，可能抛出 [ServerFailure] 或 [NetworkFailure]
  Future<List<SearchSuggestEntity>> getSearchSuggest({
    required String term,
  });

  /// 分类搜索
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
  /// 返回搜索结果，可能抛出 [ServerFailure] 或 [NetworkFailure]
  Future<List<SearchResultEntity>> searchByType({
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
  });

  /// 综合搜索
  ///
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
  /// 返回搜索结果，可能抛出 [ServerFailure] 或 [NetworkFailure]
  Future<List<SearchResultEntity>> searchAll({
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
  });

  /// 获取热搜榜
  ///
  /// [limit] 返回数量
  /// 返回热搜数据，可能抛出 [ServerFailure] 或 [NetworkFailure]
  Future<SearchTrendingDataEntity> getSearchTrending({
    int limit,
  });

  /// 获取搜索推荐
  ///
  /// 返回搜索推荐，可能抛出 [ServerFailure] 或 [NetworkFailure]
  Future<List<SearchTrendingEntity>> getSearchRecommend();

  /// 获取搜索历史
  ///
  /// 返回搜索历史实体
  SearchHistoryEntity getSearchHistory();

  /// 添加搜索历史
  ///
  /// [keyword] 搜索关键词
  void addSearchHistory(String keyword);

  /// 删除搜索历史
  ///
  /// [keyword] 搜索关键词
  void removeSearchHistory(String keyword);

  /// 清空搜索历史
  void clearSearchHistory();
}
