import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';

/// Remote data source for favorite notes
class FavNoteRemoteDatasource {
  /// Get favorite notes from API
  Future<LoadingState<List<FavNoteItemModel>?>> getFavNotes({
    required int page,
    required bool isPublish,
  }) {
    return isPublish
        ? FavHttp.userNoteList(page: page)
        : FavHttp.noteList(page: page);
  }

  /// Remove notes from favorites via API
  Future<LoadingState<void>> removeNotes({
    required Set<FavNoteItemModel> notes,
    required bool isPublish,
  }) {
    final noteIds = notes
        .map((item) => isPublish ? item.cvid : item.noteId)
        .join(',');
    return FavHttp.delNote(
      isPublish: isPublish,
      noteIds: noteIds,
    );
  }
}
