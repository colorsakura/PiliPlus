import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';
import 'package:PiliPlus/features/pgc_review/domain/repositories/pgc_review_repository.dart';
import 'package:PiliPlus/features/pgc_review/data/datasources/pgc_review_remote_datasource.dart';

/// Repository implementation for PGC review data
class PgcReviewRepositoryImpl implements PgcReviewRepository {
  const PgcReviewRepositoryImpl(this._datasource);

  final PgcReviewRemoteDatasource _datasource;

  @override
  Future<LoadingState<PgcReviewData>> getPgcReview({
    required PgcReviewType type,
    required dynamic mediaId,
    String? next,
    required int sort,
  }) => _datasource.getPgcReview(
    type: type,
    mediaId: mediaId,
    next: next,
    sort: sort,
  );

  @override
  Future<LoadingState<void>> likeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) => _datasource.likeReview(
    mediaId: mediaId,
    reviewId: reviewId,
  );

  @override
  Future<LoadingState<void>> dislikeReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) => _datasource.dislikeReview(
    mediaId: mediaId,
    reviewId: reviewId,
  );

  @override
  Future<LoadingState<void>> deleteReview({
    required dynamic mediaId,
    required dynamic reviewId,
  }) => _datasource.deleteReview(
    mediaId: mediaId,
    reviewId: reviewId,
  );
}
