import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';

/// Repository interface for favorite notes
abstract class FavNoteRepository {
  /// Get favorite notes list
  Future<LoadingState<List<FavNoteItemModel>>> getFavNotes(int page, bool isPublish);

  /// Remove notes from favorites
  Future<LoadingState<void>> removeNotes(Set<FavNoteItemModel> notes, bool isPublish);
}
