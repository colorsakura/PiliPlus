import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/repositories/fav_note_repository.dart';

/// Use case for getting favorite notes
class GetFavNotesUseCase {
  const GetFavNotesUseCase(this._repository);

  final FavNoteRepository _repository;

  Future<LoadingState<List<FavNoteItemModel>>> call(int page, bool isPublish) {
    return _repository.getFavNotes(page, isPublish);
  }
}
