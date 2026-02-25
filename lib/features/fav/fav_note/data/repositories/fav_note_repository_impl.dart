import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/repositories/fav_note_repository.dart';
import 'package:PiliPlus/features/fav/fav_note/data/datasources/fav_note_remote_datasource.dart';

/// Repository implementation for favorite notes
class FavNoteRepositoryImpl implements FavNoteRepository {
  const FavNoteRepositoryImpl(this._remoteDatasource);

  final FavNoteRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<FavNoteItemModel>>> getFavNotes(
    int page,
    bool isPublish,
  ) async {
    final result = await _remoteDatasource.getFavNotes(
      page: page,
      isPublish: isPublish,
    );
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response ?? []),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @override
  Future<LoadingState<void>> removeNotes(
    Set<FavNoteItemModel> notes,
    bool isPublish,
  ) {
    return _remoteDatasource.removeNotes(notes: notes, isPublish: isPublish);
  }
}
