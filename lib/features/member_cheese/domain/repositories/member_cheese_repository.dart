import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member cheese data
abstract class MemberCheeseRepository {
  Future<LoadingState<List<MemberCheeseItemEntity>>> fetchMemberCheeses({
    required int mid,
    required int page,
  });
}
