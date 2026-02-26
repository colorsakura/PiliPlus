import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/pgc_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/data.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/pgc_timeline.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';

/// PGC API remote data source
///
/// Handles all PGC-related API calls directly
class PgcApiDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// Get PGC index list from API
  Future<LoadingState<List<PgcIndexItem>?>> getPgcIndex({
    int? page,
    int? indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexResult,
        queryParameters: {
          'st': 1,
          'order': 3,
          'season_version': -1,
          'spoken_language_type': -1,
          'area': -1,
          'is_finish': -1,
          'copyright': -1,
          'season_status': -1,
          'season_month': -1,
          'year': -1,
          'style_id': -1,
          'sort': 0,
          'season_type': 1,
          'pagesize': 20,
          'type': 1,
          'page': page,
          'index_type': indexType,
        },
      );

      if (response.data['code'] == 0) {
        final result = response.data['data'];
        return Success(PgcIndexResult.fromJson(result).list);
      } else {
        // Return Error state instead of throwing exception
        return Error(response.data['message'] ?? '获取PGC索引失败');
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    } on ServerException catch (e) {
      return Error(e.toString());
    }
  }

  /// Get PGC timeline from API
  Future<LoadingState<List<TimelineResult>?>> getPgcTimeline({
    int types = 1,
    required int before,
    required int after,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcTimeline,
        queryParameters: {
          'types': types,
          'before': before,
          'after': after,
        },
      );

      if (response.data['code'] == 0) {
        return Success(PgcTimeline.fromJson(response.data).result);
      } else {
        // Return Error state instead of throwing exception
        return Error(response.data['message'] ?? '获取PGC时间线失败');
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    } on ServerException catch (e) {
      return Error(e.toString());
    }
  }

  /// Get PGC index result from API
  Future<LoadingState<Map<String, dynamic>>> getPgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    Object? seasonType,
    Object? type,
    Object? indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexResult,
        queryParameters: {
          ...params,
          'season_type': seasonType,
          'type': type,
          'index_type': indexType,
          'page': page,
          'pagesize': 21,
        },
      );

      if (response.data['code'] == 0) {
        return Success(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC索引结果失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Get PGC index condition from API
  Future<LoadingState<Map<String, dynamic>>> getPgcIndexCondition({
    Object? seasonType,
    required Object type,
    Object? indexType,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.pgcIndexCondition,
        queryParameters: {
          'season_type': seasonType,
          'type': type,
          'index_type': indexType,
        },
      );

      if (response.data['code'] == 0) {
        return Success(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC索引条件失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Get season status from API
  Future<LoadingState<Map<String, dynamic>>> getSeasonStatus(
    Object seasonId,
  ) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.seasonStatus,
        queryParameters: {'season_id': seasonId},
      );

      if (response.data['code'] == 0) {
        return Success(response.data['result']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取季度状态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Get PGC follow list (favorite anime/cinema)
  Future<LoadingState<List<FavPgcItemModel>?>> getPgcFollowList({
    required int page,
    required int type,
  }) async {
    try {
      final response = await _httpClient.get(
        PgcApiConstants.favPgc,
        queryParameters: {
          'vmid': Accounts.main.mid,
          'type': type,
          'pn': page,
        },
      );

      if (response.data['code'] == 0) {
        final data = response.data['data'];
        if (data != null && data['list'] != null) {
          final list = (data['list'] as List)
              .map((e) => FavPgcItemModel.fromJson(e))
              .toList();
          return Success(list);
        }
        return Success(const []);
      } else {
        // Return Error state instead of throwing exception
        return Error(response.data['message'] ?? '获取PGC关注列表失败');
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    } on ServerException catch (e) {
      return Error(e.toString());
    }
  }
}
