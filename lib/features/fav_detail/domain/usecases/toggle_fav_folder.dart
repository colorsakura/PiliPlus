import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';
import 'package:PiliPlus/features/fav_detail/domain/repositories/fav_detail_repository.dart';

/// Use case for favoriting or unfavoriting a folder
class ToggleFavFolder {
  final FavDetailRepository repository;

  const ToggleFavFolder(this.repository);

  Future<LoadingState<Null>> call(ToggleFavFolderParams params) =>
      repository.toggleFavFolder(params);
}
