import 'package:PiliPlus/features/member_comic/domain/entities/member_comic_item_entity.dart';
import 'package:PiliPlus/features/member_comic/domain/repositories/member_comic_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member comics
class FetchMemberComicsUseCase {
  const FetchMemberComicsUseCase(this._repository);

  final MemberComicRepository _repository;

  Future<LoadingState<List<MemberComicItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberComics(mid: mid, page: page);
  }
}
