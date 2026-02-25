import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/pgc_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';

/// Remote datasource for PGC review data
class PgcReviewRemoteDatasource {
  final Dio _httpClient = HttpClientManager.instance;

  /// Fetch PGC reviews from API
  Future<LoadingState<PgcReviewData>> getPgcReview({
    required PgcReviewType type,
    required dynamic mediaId,
    String? next,
    required int sort,
  }) async {
    try {
      final response = await _httpClient.get(
        type.api,
        queryParameters: {
          'media_id': mediaId,
          'ps': 20,
          'sort': sort,
          'cursor': next,
          'web_location': 666.19,
        },
      );

      if (response.data['code'] == 0) {
        return Success(PgcReviewData.fromJson(response.data['data']));
      } else {
        throw ServerException(
          response.data['message'] ?? '获取PGC评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Like a review
  Future<LoadingState<void>> likeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewLike,
        data: {
          'media_id': mediaId,
          'review_type': 2,
          'review_id': reviewId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        throw ServerException(
          response.data['message'] ?? '点赞评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Dislike a review
  Future<LoadingState<void>> dislikeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewDislike,
        data: {
          'media_id': mediaId,
          'review_type': 2,
          'review_id': reviewId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        throw ServerException(
          response.data['message'] ?? '取消点赞评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Delete a review
  Future<LoadingState<void>> deleteReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewDel,
        data: {
          'media_id': mediaId,
          'review_id': reviewId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        throw ServerException(
          response.data['message'] ?? '删除评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Post a new review
  Future<LoadingState<void>> postReview({
    required dynamic mediaId,
    required int score,
    required String content,
    bool shareFeed = false,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewPost,
        data: {
          'media_id': mediaId,
          'score': score,
          'content': content,
          if (shareFeed) 'share_feed': 1,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        throw ServerException(
          response.data['message'] ?? '发布评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }

  /// Modify an existing review
  Future<LoadingState<void>> modifyReview({
    required dynamic mediaId,
    required int score,
    required String content,
    required reviewId,
  }) async {
    try {
      final response = await _httpClient.post(
        PgcApiConstants.pgcReviewMod,
        data: {
          'media_id': mediaId,
          'score': score,
          'content': content,
          'review_id': reviewId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return const Success(null);
      } else {
        throw ServerException(
          response.data['message'] ?? '修改评论失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      return Error(ErrorHandler.handleDioError(e).toString());
    }
  }
}
