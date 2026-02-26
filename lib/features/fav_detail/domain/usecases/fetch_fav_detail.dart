import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';
import 'package:PiliPlus/features/fav_detail/domain/repositories/fav_detail_repository.dart';

/// Use case for fetching favorite folder detail
class FetchFavDetail {
  final FavDetailRepository repository;

  const FetchFavDetail(this.repository);

  Future<LoadingState<FavDetailData>> call(FetchFavDetailParams params) =>
      repository.fetchFavDetail(params);
}
