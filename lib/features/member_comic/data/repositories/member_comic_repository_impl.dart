import 'package:PiliPlus/features/member_comic/domain/entities/member_comic_item_entity.dart';
import 'package:PiliPlus/features/member_comic/domain/repositories/member_comic_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';

/// Implementation of member comic repository
class MemberComicRepositoryImpl implements MemberComicRepository {
  const MemberComicRepositoryImpl();

  @override
  Future<LoadingState<List<MemberComicItemEntity>>> fetchMemberComics({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.spaceArchive(
      type: ContributeType.comic,
      mid: mid,
    );

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.item ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
