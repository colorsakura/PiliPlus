import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/repositories/member_upower_rank_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/upower_rank/data.dart';

/// Implementation of member upower rank repository
class MemberUpowerRankRepositoryImpl
    implements MemberUpowerRankRepository {
  const MemberUpowerRankRepositoryImpl();

  @override
  Future<LoadingState<List<MemberUpowerRankItemEntity>>> fetchMemberUpowerRank({
    required String upMid,
    required int page,
    int? privilegeType,
  }) async {
    final result = await MemberHttp.upowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.rankInfo ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
