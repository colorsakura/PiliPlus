import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_cheese/data/repositories/member_cheese_repository_impl.dart';
import 'package:PiliPlus/features/member_cheese/domain/usecases/fetch_member_cheeses.dart';
import 'package:PiliPlus/features/member_cheese/presentation/providers/member_cheese_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberCheeseRepositoryProvider = Provider<MemberCheeseRepositoryImpl>((
  ref,
) {
  return MemberCheeseRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberCheesesUseCaseProvider = Provider<FetchMemberCheesesUseCase>(
  (ref) {
    return FetchMemberCheesesUseCase(
      ref.watch(memberCheeseRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberCheeseListControllerProvider =
    Provider.family<MemberCheeseListController, int>((ref, mid) {
  return MemberCheeseListController(
    mid: mid,
    fetchCheeses: ref.watch(fetchMemberCheesesUseCaseProvider),
  );
});
