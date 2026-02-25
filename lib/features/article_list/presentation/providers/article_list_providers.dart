import 'package:PiliPlus/features/article_list/data/datasources/article_list_remote_datasource.dart';
import 'package:PiliPlus/features/article_list/data/repositories/article_list_repository_impl.dart';
import 'package:PiliPlus/features/article_list/domain/repositories/article_list_repository.dart';
import 'package:PiliPlus/features/article_list/domain/usecases/get_article_list.dart';
import 'package:PiliPlus/features/article_list/presentation/providers/article_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Article list remote data source provider
final articleListRemoteDataSourceProvider =
    Provider<ArticleListRemoteDataSource>((ref) {
      return ArticleListRemoteDataSource();
    });

/// Article list repository provider
final articleListRepositoryProvider = Provider<ArticleListRepository>((ref) {
  final remoteDataSource = ref.watch(articleListRemoteDataSourceProvider);
  return ArticleListRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Get article list use case provider
final getArticleListUseCaseProvider = Provider<GetArticleListUseCase>((ref) {
  final repository = ref.watch(articleListRepositoryProvider);
  return GetArticleListUseCase(repository);
});

/// Article list controller provider
final articleListControllerProvider =
    NotifierProvider<ArticleListController, ArticleListState>(
      ArticleListController.new,
    );
