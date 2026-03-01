import 'dart:convert';

import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/search/data/datasources/search_remote_datasource.dart';
import 'package:PiliPlus/features/search/domain/entities/search_history_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_result_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_suggest_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_trending_entity.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/models/search/suggest.dart';

/// 搜索仓库实现
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SearchSuggestEntity>> getSearchSuggest({
    required String term,
  }) async {
    try {
      final result = await _remoteDataSource.searchSuggest(term: term);
      if (result == null) {
        return const [];
      }
      final suggestModel = SearchSuggestModel.fromJson(result);
      return suggestModel.tag?.map((item) {
        return SearchSuggestEntity(
          term: item.term,
          textRich: item.textRich,
        );
      }).toList() ?? const [];
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
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
  }) async {
    try {
      final data = await _remoteDataSource.searchByType(
        searchType: searchType.name,
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

      // 根据搜索类型转换结果
      switch (searchType) {
        case SearchType.video:
          final videoData = SearchVideoData.fromJson(data);
          return videoData.list?.map((item) {
            final searchOwner = item.owner as SearchOwner?;
            final searchStat = item.stat as SearchStat?;
            return SearchVideoEntity(
              type: item.type,
              id: item.id,
              aid: item.aid,
              bvid: item.bvid,
              title: item.title,
              desc: item.desc,
              cover: item.cover,
              pubdate: item.pubdate,
              ctime: item.ctime,
              duration: item.duration,
              owner: SearchOwnerEntity(
                mid: searchOwner?.mid,
                name: searchOwner?.name,
                face: searchOwner?.face,
              ),
              stat: SearchStatEntity(
                view: searchStat?.view,
                danmu: searchStat?.danmu,
                favorite: searchStat?.favorite,
                reply: searchStat?.reply,
                like: searchStat?.like,
              ),
              isUnionVideo: item.isUnionVideo,
              titleList: item.titleList,
            );
          }).toList() ?? [];

        case SearchType.bili_user:
          final userData = SearchUserData.fromJson(data);
          return userData.list?.map((item) {
            return SearchUserEntity(
              type: item.type,
              mid: item.mid,
              uname: item.uname,
              usign: item.usign,
              fans: item.fans,
              videos: item.videos,
              upic: item.upic,
              isLive: item.isLive,
              roomId: item.roomId,
              level: item.level,
            );
          }).toList() ?? [];

        case SearchType.live_room:
          final liveData = SearchLiveData.fromJson(data);
          return liveData.list?.map((item) {
            return SearchVideoEntity(
              type: item.type,
              title: item.title.map((e) => e.text).join(),
              cover: item.cover ?? item.pic,
            );
          }).toList() ?? [];

        case SearchType.media_bangumi:
        case SearchType.media_ft:
          final pgcData = SearchPgcData.fromJson(data);
          return pgcData.list?.map((item) {
            return SearchVideoEntity(
              type: item.type,
              title: item.title.map((e) => e.text).join(),
              cover: item.cover,
            );
          }).toList() ?? [];

        case SearchType.article:
          final articleData = SearchArticleData.fromJson(data);
          return articleData.list?.map((item) {
            return SearchVideoEntity(
              type: item.type,
              title: item.title.map((e) => e.text).join(),
              desc: item.desc,
            );
          }).toList() ?? [];

        default:
          return [];
      }
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
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
  }) async {
    try {
      final data = await _remoteDataSource.searchAll(
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
      );

      final allData = SearchAllData.fromJson(data);

      // SearchAllData.list 返回的是 List<dynamic>
      // 需要转换为 List<SearchResultEntity>
      // 这里先返回空列表，因为综合搜索结果类型复杂
      // 实际使用时可以根据需要解析
      return [];
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<SearchTrendingDataEntity> getSearchTrending({
    int limit = 30,
  }) async {
    try {
      final data = await _remoteDataSource.searchTrending(limit: limit);
      final trendingData = _parseTrendingData(data);
      return trendingData;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<List<SearchTrendingEntity>> getSearchRecommend() async {
    try {
      final data = await _remoteDataSource.searchRecommend();
      final list = (data['list'] as List?)
          ?.map((e) => SearchTrendingEntity.fromModel(e))
          .toList();
      return list ?? const [];
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  SearchHistoryEntity getSearchHistory() {
    final historyListJson =
        GStorage.historyWordRepository.getString('cacheList') ?? '[]';
    final historyList = List<String>.from(jsonDecode(historyListJson));
    return SearchHistoryEntity(
      historyList: historyList,
      recordHistory: true,
    );
  }

  @override
  void addSearchHistory(String keyword) {
    final history = getSearchHistory();
    final updatedHistory = history.addHistory(keyword);
    GStorage.historyWordRepository.setString(
      'cacheList',
      jsonEncode(updatedHistory.historyList),
    );
  }

  @override
  void removeSearchHistory(String keyword) {
    final history = getSearchHistory();
    final updatedHistory = history.removeHistory(keyword);
    GStorage.historyWordRepository.setString(
      'cacheList',
      jsonEncode(updatedHistory.historyList),
    );
  }

  @override
  void clearSearchHistory() {
    GStorage.historyWordRepository.remove('cacheList');
  }

  SearchTrendingDataEntity _parseTrendingData(Map<String, dynamic> data) {
    final list = (data['list'] as List?)
        ?.map((e) => SearchTrendingEntity.fromModel(e))
        .toList();
    final topList = (data['top_list'] as List?)
        ?.map((e) => SearchTrendingEntity.fromModel(e))
        .toList();
    return SearchTrendingDataEntity(
      list: list,
      topList: topList,
    );
  }
}
