import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/usecases/get_fav_folders_usecase.dart';
import 'package:PiliPlus/features/fav/fav_video/data/repositories/fav_video_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_video/data/datasources/fav_video_remote_datasource.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_video/presentation/providers/fav_video_providers.dart';

part 'fav_folder_list_controller.g.dart';

/// Fav folder list state
class FavFolderListState {
  final List<FavFolderInfo>? folders;
  final int currentPage;
  final bool isEnd;
  final bool isLoading;
  final String? errorMessage;

  const FavFolderListState({
    this.folders,
    this.currentPage = 1,
    this.isEnd = false,
    this.isLoading = false,
    this.errorMessage,
  });

  FavFolderListState copyWith({
    List<FavFolderInfo>? folders,
    int? currentPage,
    bool? isEnd,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavFolderListState(
      folders: folders ?? this.folders,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing favorite folders
@riverpod
class FavFolderListController extends _$FavFolderListController {
  @override
  FavFolderListState build() {
    // Fetch data on initialization
    fetchFolders();
    return const FavFolderListState();
  }

  /// Fetch favorite folders
  Future<void> fetchFolders({bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : currentState.currentPage;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getFolders = ref.read(getFavFoldersUseCaseProvider);
      final result = await getFolders(page);

      switch (result) {
        case Success(:final response):
          final newFolders = response;
          final existingFolders = isRefresh ? [] : (state.folders ?? []);

          state = state.copyWith(
            folders: [...existingFolders, ...newFolders],
            currentPage: page + 1,
            isEnd: newFolders.isEmpty,
            isLoading: false,
          );
        case Error(:final errMsg):
          state = state.copyWith(
            isLoading: false,
            errorMessage: errMsg,
          );
        case Loading():
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear folders
  void clearFolders() {
    state = const FavFolderListState();
  }
}
