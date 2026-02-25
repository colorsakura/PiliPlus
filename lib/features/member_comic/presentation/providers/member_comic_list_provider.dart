import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_comic/data/repositories/member_comic_repository_impl.dart';
import 'package:PiliPlus/features/member_comic/domain/usecases/fetch_member_comics.dart';
import 'package:PiliPlus/features/member_comic/presentation/providers/member_comic_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberComicRepositoryProvider = Provider<MemberComicRepositoryImpl>((
  ref,
) {
  return MemberComicRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberComicsUseCaseProvider = Provider<FetchMemberComicsUseCase>(
  (ref) {
    return FetchMemberComicsUseCase(
      ref.watch(memberComicRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberComicListControllerProvider =
    Provider.family<MemberComicListController, int>((ref, mid) {
  return MemberComicListController(
    mid: mid,
    fetchComics: ref.watch(fetchMemberComicsUseCaseProvider),
  );
});
