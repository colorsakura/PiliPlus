import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_shop/data/repositories/member_shop_repository_impl.dart';
import 'package:PiliPlus/features/member_shop/domain/usecases/fetch_member_shop_items.dart';
import 'package:PiliPlus/features/member_shop/presentation/providers/member_shop_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberShopRepositoryProvider = Provider<MemberShopRepositoryImpl>((
  ref,
) {
  return MemberShopRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberShopItemsUseCaseProvider =
    Provider<FetchMemberShopItemsUseCase>(
  (ref) {
    return FetchMemberShopItemsUseCase(
      ref.watch(memberShopRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberShopListControllerProvider =
    Provider.family<MemberShopListController, int>((ref, mid) {
  return MemberShopListController(
    mid: mid,
    fetchShopItems: ref.watch(fetchMemberShopItemsUseCaseProvider),
  );
});
