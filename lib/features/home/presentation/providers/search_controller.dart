import 'package:PiliPlus/features/home/presentation/providers/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 搜索建议状态
class SearchSuggestionState {
  final String defaultSearch;
  final bool isLoading;
  final String? errorMessage;

  const SearchSuggestionState({
    this.defaultSearch = '',
    this.isLoading = false,
    this.errorMessage,
  });

  SearchSuggestionState copyWith({
    String? defaultSearch,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchSuggestionState(
      defaultSearch: defaultSearch ?? this.defaultSearch,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 搜索建议 Controller
class SearchSuggestionController extends Notifier<SearchSuggestionState> {
  @override
  SearchSuggestionState build() {
    // 启动异步获取搜索建议
    Future.microtask(fetchDefaultSearch);
    return const SearchSuggestionState();
  }

  /// 获取默认搜索建议
  Future<void> fetchDefaultSearch() async {
    final useCase = ref.read(fetchSearchSuggestionUseCaseProvider);
    state = state.copyWith(isLoading: true);
    try {
      final suggestion = await useCase();
      state = state.copyWith(
        defaultSearch: suggestion?.displayText ?? '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 清除搜索建议
  void clear() {
    state = state.copyWith(defaultSearch: '');
  }
}

/// 搜索建议 Provider
final searchSuggestionControllerProvider =
    NotifierProvider<SearchSuggestionController, SearchSuggestionState>(
      SearchSuggestionController.new,
    );
