import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_coin_arc/data/repositories/member_coin_arc_repository_impl.dart';
import 'package:PiliPlus/features/member_coin_arc/domain/usecases/fetch_member_coin_arcs.dart';
import 'package:PiliPlus/features/member_coin_arc/presentation/providers/member_coin_arc_list_controller.dart';

final memberCoinArcRepositoryProvider = Provider<MemberCoinArcRepositoryImpl>((
  ref,
) {
  return const MemberCoinArcRepositoryImpl();
});

final fetchMemberCoinArcsUseCaseProvider = Provider<FetchMemberCoinArcsUseCase>(
  (ref) {
    return FetchMemberCoinArcsUseCase(
      ref.watch(memberCoinArcRepositoryProvider),
    );
  },
);

final memberCoinArcListControllerProvider =
    Provider.family<MemberCoinArcListController, dynamic>((ref, mid) {
      return MemberCoinArcListController(
        mid: mid,
        fetchCoinArcs: ref.watch(fetchMemberCoinArcsUseCaseProvider),
      );
    });
