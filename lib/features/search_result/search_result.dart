// Domain exports
export 'package:PiliPlus/features/search_result/domain/entities/search_result_state.dart'
    show SearchResultStateEntity;
export 'package:PiliPlus/features/search_result/domain/repositories/search_result_repository.dart'
    show SearchResultRepository;
export 'package:PiliPlus/features/search_result/domain/usecases/manage_search_result_state.dart'
    show ManageSearchResultState;

// Data exports
export 'package:PiliPlus/features/search_result/data/datasources/search_result_memory_datasource.dart'
    show SearchResultMemoryDataSource, SearchResultMemoryDataSourceImpl;
export 'package:PiliPlus/features/search_result/data/repositories/search_result_repository_impl.dart'
    show SearchResultRepositoryImpl;

// Presentation exports - Riverpod implementation
export 'package:PiliPlus/features/search_result/presentation/pages/search_result_page_v2.dart'
    show SearchResultPageV2;
export 'package:PiliPlus/features/search_result/presentation/providers/search_result_providers.dart'
    show searchResultControllerProvider;
export 'package:PiliPlus/features/search_result/presentation/providers/search_result_controller.dart'
    show SearchResultState, SearchResultController;
