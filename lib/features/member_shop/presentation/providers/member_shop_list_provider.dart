import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_shop/data/repositories/member_shop_repository_impl.dart';
import 'package:PiliPlus/features/member_shop/domain/usecases/fetch_member_shop_items.dart';
import 'package:PiliPlus/features/member_shop/presentation/providers/member_shop_list_controller.dart';

final memberShopRepositoryProvider = Provider<MemberShopRepositoryImpl>((ref) {
  return const MemberShopRepositoryImpl();
});

final fetchMemberShopItemsUseCaseProvider =
    Provider<FetchMemberShopItemsUseCase>((ref) {
  return FetchMemberShopItemsUseCase(
    ref.watch(memberShopRepositoryProvider),
  );
});

final memberShopListControllerProvider =
    Provider.family<MemberShopListController, int>((ref, mid) {
  return MemberShopListController(
    mid: mid,
    fetchShopItems: ref.watch(fetchMemberShopItemsUseCaseProvider),
  );
});
