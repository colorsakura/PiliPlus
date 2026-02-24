import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/features/member_cheese/domain/repositories/member_cheese_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space/space_cheese/data.dart';

/// Implementation of member cheese repository
class MemberCheeseRepositoryImpl implements MemberCheeseRepository {
  const MemberCheeseRepositoryImpl();

  @override
  Future<LoadingState<List<MemberCheeseItemEntity>>> fetchMemberCheeses({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.spaceCheese(
      page: page,
      mid: mid,
    );

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.items ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
