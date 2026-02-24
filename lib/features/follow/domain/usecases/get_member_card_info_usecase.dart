import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member_card_info/data.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Use case for getting member card info
class GetMemberCardInfoUseCase {
  const GetMemberCardInfoUseCase(this._repository);

  final FollowRepository _repository;

  Future<LoadingState<MemberCardInfoData>> call(int mid) =>
      _repository.getMemberCardInfo(mid);
}
