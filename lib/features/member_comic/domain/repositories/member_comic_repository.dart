import 'package:PiliPlus/features/member_comic/domain/entities/member_comic_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member comic data
abstract class MemberComicRepository {
  Future<LoadingState<List<MemberComicItemEntity>>> fetchMemberComics({
    required int mid,
    required int page,
  });
}
