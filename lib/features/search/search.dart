// 页面导出
export 'presentation/pages/search_page.dart' show SearchPage;

// Riverpod Providers (新)
export 'presentation/providers/search_providers.dart'
    show
        searchControllerProvider,
        searchRemoteDataSourceProvider,
        searchRepositoryProvider,
        getSearchSuggestUseCaseProvider,
        searchByTypeUseCaseProvider,
        getSearchTrendingUseCaseProvider,
        getSearchRecommendUseCaseProvider,
        manageSearchHistoryUseCaseProvider,
        searchSuggestionEnabledProvider,
        trendingEnabledProvider,
        searchRcmdEnabledProvider,
        recordSearchHistoryProvider;

// State (新)
export 'presentation/providers/search_state.dart' show SearchState;

// Controller (新 - Riverpod)
export 'presentation/providers/search_controller.dart' show SearchController;

// Entities
export 'domain/entities/search_suggest_entity.dart' show SearchSuggestEntity;
export 'domain/entities/search_result_entity.dart'
    show
        SearchResultEntity,
        SearchVideoEntity,
        SearchUserEntity,
        SearchOwnerEntity,
        SearchStatEntity;
export 'domain/entities/search_trending_entity.dart'
    show SearchTrendingEntity, SearchTrendingDataEntity;
export 'domain/entities/search_history_entity.dart' show SearchHistoryEntity;

// Repository
export 'domain/repositories/search_repository.dart' show SearchRepository;

// Use Cases
export 'domain/usecases/get_search_suggest.dart' show GetSearchSuggestUseCase;
export 'domain/usecases/search_by_type.dart' show SearchByTypeUseCase;
export 'domain/usecases/get_search_trending.dart' show GetSearchTrendingUseCase;
export 'domain/usecases/get_search_recommend.dart' show GetSearchRecommendUseCase;
export 'domain/usecases/manage_search_history.dart' show ManageSearchHistoryUseCase;

