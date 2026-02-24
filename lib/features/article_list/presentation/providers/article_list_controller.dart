import 'package:PiliPlus/features/article_list/domain/entities/article_list_item.dart';
import 'package:PiliPlus/features/article_list/domain/usecases/get_article_list.dart';
import 'package:PiliPlus/features/article_list/presentation/providers/article_list_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Article list state
class ArticleListState {
  /// Loading state for article list data
  final LoadingState<ArticleListDataEntity> loadingState;

  const ArticleListState({
    required this.loadingState,
  });

  /// Copy with
  ArticleListState copyWith({
    LoadingState<ArticleListDataEntity>? loadingState,
  }) {
    return ArticleListState(
      loadingState: loadingState ?? this.loadingState,
    );
  }
}

/// Article list controller
///
/// Manages article list state and operations
class ArticleListController extends Notifier<ArticleListState> {
  late final GetArticleListUseCase _getArticleListUseCase;
  String _id = '';

  /// Set the article list ID
  void setId(String id) {
    if (_id != id) {
      _id = id;
      queryArticleList();
    }
  }

  @override
  ArticleListState build() {
    _getArticleListUseCase = ref.read(getArticleListUseCaseProvider);
    return ArticleListState(
      loadingState: LoadingState.loading(),
    );
  }

  /// Query article list
  Future<void> queryArticleList() async {
    if (_id.isEmpty) return;

    state = state.copyWith(
      loadingState: LoadingState.loading(),
    );

    final result = await _getArticleListUseCase(_id);
    state = state.copyWith(loadingState: result);
  }

  /// Refresh the list
  Future<void> onRefresh() {
    return queryArticleList();
  }

  /// Reload on error
  void onReload() {
    queryArticleList();
  }
}
