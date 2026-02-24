import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_cheese/data/repositories/member_cheese_repository_impl.dart';
import 'package:PiliPlus/features/member_cheese/domain/usecases/fetch_member_cheeses.dart';
import 'package:PiliPlus/features/member_cheese/presentation/providers/member_cheese_list_controller.dart';

final memberCheeseRepositoryProvider = Provider<MemberCheeseRepositoryImpl>((ref) {
  return const MemberCheeseRepositoryImpl();
});

final fetchMemberCheesesUseCaseProvider = Provider<FetchMemberCheesesUseCase>((ref) {
  return FetchMemberCheesesUseCase(
    ref.watch(memberCheeseRepositoryProvider),
  );
});

final memberCheeseListControllerProvider =
    Provider.family<MemberCheeseListController, int>((ref, mid) {
  return MemberCheeseListController(
    mid: mid,
    _fetchCheeses: ref.watch(fetchMemberCheesesUseCaseProvider),
  );
});
