import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/repositories/fav_note_repository.dart';

/// Use case for removing notes from favorites
class RemoveNotesUseCase {
  const RemoveNotesUseCase(this._repository);

  final FavNoteRepository _repository;

  Future<LoadingState<void>> call(Set<FavNoteItemModel> notes, bool isPublish) {
    return _repository.removeNotes(notes, isPublish);
  }
}
