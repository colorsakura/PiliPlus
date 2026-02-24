import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_comic/data/repositories/member_comic_repository_impl.dart';
import 'package:PiliPlus/features/member_comic/domain/usecases/fetch_member_comics.dart';
import 'package:PiliPlus/features/member_comic/presentation/providers/member_comic_list_controller.dart';

final memberComicRepositoryProvider = Provider<MemberComicRepositoryImpl>((ref) {
  return const MemberComicRepositoryImpl();
});

final fetchMemberComicsUseCaseProvider = Provider<FetchMemberComicsUseCase>((ref) {
  return FetchMemberComicsUseCase(
    ref.watch(memberComicRepositoryProvider),
  );
});

final memberComicListControllerProvider =
    Provider.family<MemberComicListController, int>((ref, mid) {
  return MemberComicListController(
    mid: mid,
    fetchComics: ref.watch(fetchMemberComicsUseCaseProvider),
  );
});
