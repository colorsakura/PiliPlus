import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/pgc.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';

/// Remote datasource for PGC review data
class PgcReviewRemoteDatasource {
  const PgcReviewRemoteDatasource();

  /// Fetch PGC reviews from API
  Future<LoadingState<PgcReviewData>> getPgcReview({
    required PgcReviewType type,
    required dynamic mediaId,
    String? next,
    required int sort,
  }) =>
      PgcHttp.pgcReview(
        type: type,
        mediaId: mediaId,
        next: next,
        sort: sort,
      );

  /// Like a review
  Future<LoadingState<void>> likeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) =>
      PgcHttp.pgcReviewLike(
        mediaId: mediaId,
        reviewId: reviewId,
      );

  /// Dislike a review
  Future<LoadingState<void>> dislikeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) =>
      PgcHttp.pgcReviewDislike(
        mediaId: mediaId,
        reviewId: reviewId,
      );

  /// Delete a review
  Future<LoadingState<void>> deleteReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) =>
      PgcHttp.pgcReviewDel(
        mediaId: mediaId,
        reviewId: reviewId,
      );
}
