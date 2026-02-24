import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';

/// Repository for PGC review data
abstract class PgcReviewRepository {
  /// Fetch PGC reviews
  Future<LoadingState<PgcReviewData>> getPgcReview({
    required PgcReviewType type,
    required dynamic mediaId,
    String? next,
    required int sort,
  });

  /// Like a review
  Future<LoadingState<void>> likeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  });

  /// Dislike a review
  Future<LoadingState<void>> dislikeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  });

  /// Delete a review
  Future<LoadingState<void>> deleteReview({
    required dynamic mediaId,
    required dynamic reviewId,
  });
}
