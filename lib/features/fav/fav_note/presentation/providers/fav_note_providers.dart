import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_note/data/datasources/fav_note_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_note/data/repositories/fav_note_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/repositories/fav_note_repository.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/usecases/get_fav_notes_usecase.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/usecases/remove_notes_usecase.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_list_controller.dart';

/// Provider for FavNoteRemoteDatasource
final favNoteRemoteDatasourceProvider = Provider<FavNoteRemoteDatasource>((
  ref,
) {
  return FavNoteRemoteDatasource();
});

/// Provider for FavNoteRepository
final favNoteRepositoryProvider = Provider<FavNoteRepository>((ref) {
  final datasource = ref.watch(favNoteRemoteDatasourceProvider);
  return FavNoteRepositoryImpl(datasource);
});

/// Provider for GetFavNotesUseCase
final getFavNotesUseCaseProvider = Provider<GetFavNotesUseCase>((ref) {
  final repository = ref.watch(favNoteRepositoryProvider);
  return GetFavNotesUseCase(repository);
});

/// Provider for RemoveNotesUseCase
final removeNotesUseCaseProvider = Provider<RemoveNotesUseCase>((ref) {
  final repository = ref.watch(favNoteRepositoryProvider);
  return RemoveNotesUseCase(repository);
});

/// Provider family for FavNoteController (parametrized by isPublish)
final favNoteControllerProvider = Provider.family<FavNoteController, bool>((
  ref,
  isPublish,
) {
  return FavNoteController(
    isPublish: isPublish,
    getFavNotesUseCase: ref.watch(getFavNotesUseCaseProvider),
    removeNotesUseCase: ref.watch(removeNotesUseCaseProvider),
  );
});
