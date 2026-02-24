import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_upower_rank/data/repositories/member_upower_rank_repository_impl.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/usecases/fetch_member_upower_rank.dart';
import 'package:PiliPlus/features/member_upower_rank/presentation/providers/member_upower_rank_list_controller.dart';

final memberUpowerRankRepositoryProvider =
    Provider<MemberUpowerRankRepositoryImpl>((ref) {
  return const MemberUpowerRankRepositoryImpl();
});

final fetchMemberUpowerRankUseCaseProvider =
    Provider<FetchMemberUpowerRankUseCase>((ref) {
  return FetchMemberUpowerRankUseCase(
    ref.watch(memberUpowerRankRepositoryProvider),
  );
});

final memberUpowerRankListControllerProvider = Provider.family<
    MemberUpowerRankListController,
    ({String upMid, int? privilegeType})>((ref, params) {
  return MemberUpowerRankListController(
    upMid: params.upMid,
    privilegeType: params.privilegeType,
    fetchUpowerRank: ref.watch(fetchMemberUpowerRankUseCaseProvider),
  );
});
