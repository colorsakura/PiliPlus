import 'package:PiliPlus/features/member_article/domain/entities/member_article_item_entity.dart';
import 'package:PiliPlus/features/member_article/domain/usecases/fetch_member_articles.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// State for member article list
class MemberArticleListState {
  MemberArticleListState({
    LoadingState<List<MemberArticleItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.count = -1,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberArticleItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int count;

  MemberArticleListState copyWith({
    LoadingState<List<MemberArticleItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? count,
  }) {
    return MemberArticleListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      count: count ?? this.count,
    );
  }
}

/// Controller for member article list
///
/// This controller manages the paginated list of articles for a member.
/// It follows the ChangeNotifier pattern used in the project.
class MemberArticleListController extends ChangeNotifier {
  MemberArticleListController({
    required this.mid,
    required FetchMemberArticlesUseCase fetchArticles,
  }) : _fetchArticles = fetchArticles {
    // Load initial data
    queryData(isRefresh: true);
  }

  final int mid;
  final FetchMemberArticlesUseCase _fetchArticles;

  MemberArticleListState _state = MemberArticleListState();

  MemberArticleListState get state => _state;

  /// Query data with pagination
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchArticles(mid: mid, page: page);

    if (result is Loading) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: LoadingState.loading(),
          isLoading: false,
        );
      }
    } else if (result is Error) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: result,
          isLoading: false,
        );
      }
    } else if (result is Success<List<MemberArticleItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        _state = _state.copyWith(
          isEnd: true,
          isLoading: false,
        );
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
            count: dataList.length,
          );
        } else {
          // Append to existing list
          final currentState = _state.listState;
          if (currentState is Success<List<MemberArticleItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            _state = _state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
            );
          }
        }
      }
    }

    notifyListeners();
  }

  /// Refresh the list
  Future<void> onRefresh() async {
    _state = _state.copyWith(
      currentPage: 1,
      isEnd: false,
    );
    return queryData(isRefresh: true);
  }

  /// Reload current page
  Future<void> onReload() {
    _state = _state.copyWith(
      listState: LoadingState.loading(),
    );
    notifyListeners();
    return queryData(isRefresh: true);
  }

  /// Load more items
  Future<void> onLoadMore() {
    return queryData(isRefresh: false);
  }
}
