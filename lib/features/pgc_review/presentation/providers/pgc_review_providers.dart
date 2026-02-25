import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/features/pgc_review/data/datasources/pgc_review_remote_datasource.dart';
import 'package:PiliPlus/features/pgc_review/data/repositories/pgc_review_repository_impl.dart';
import 'package:PiliPlus/features/pgc_review/domain/repositories/pgc_review_repository.dart';
import 'package:PiliPlus/features/pgc_review/presentation/providers/pgc_review_controller.dart';

// Remote Datasource Provider
final pgcReviewRemoteDatasourceProvider =
    Provider<PgcReviewRemoteDatasource>((ref) {
  return PgcReviewRemoteDatasource();
});

// Repository Provider
final pgcReviewRepositoryProvider = Provider<PgcReviewRepository>((ref) {
  final datasource = ref.watch(pgcReviewRemoteDatasourceProvider);
  return PgcReviewRepositoryImpl(datasource);
});

/// Controller parameters
class PgcReviewParams {
  const PgcReviewParams({
    required this.type,
    required this.mediaId,
  });

  final PgcReviewType type;
  final dynamic mediaId;
}

// Controller Provider - uses Provider.family for different params
final pgcReviewControllerProvider =
    Provider.family<PgcReviewController, PgcReviewParams>((ref, params) {
  return PgcReviewController(
    type: params.type,
    mediaId: params.mediaId,
    repository: ref.watch(pgcReviewRepositoryProvider),
  );
});
