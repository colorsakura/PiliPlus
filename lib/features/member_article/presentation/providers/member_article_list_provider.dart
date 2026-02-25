import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_article/data/repositories/member_article_repository_impl.dart';
import 'package:PiliPlus/features/member_article/domain/usecases/fetch_member_articles.dart';
import 'package:PiliPlus/features/member_article/presentation/providers/member_article_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberArticleRepositoryProvider = Provider<MemberArticleRepositoryImpl>((
  ref,
) {
  return MemberArticleRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberArticlesUseCaseProvider = Provider<FetchMemberArticlesUseCase>(
  (ref) {
    return FetchMemberArticlesUseCase(
      ref.watch(memberArticleRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberArticleListControllerProvider =
    Provider.family<MemberArticleListController, int>((ref, mid) {
  return MemberArticleListController(
    mid: mid,
    fetchArticles: ref.watch(fetchMemberArticlesUseCaseProvider),
  );
});
