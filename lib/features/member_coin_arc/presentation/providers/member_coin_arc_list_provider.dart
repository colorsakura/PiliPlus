import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_coin_arc/data/repositories/member_coin_arc_repository_impl.dart';
import 'package:PiliPlus/features/member_coin_arc/domain/usecases/fetch_member_coin_arcs.dart';
import 'package:PiliPlus/features/member_coin_arc/presentation/providers/member_coin_arc_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberCoinArcRepositoryProvider = Provider<MemberCoinArcRepositoryImpl>((
  ref,
) {
  return MemberCoinArcRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberCoinArcsUseCaseProvider = Provider<FetchMemberCoinArcsUseCase>(
  (ref) {
    return FetchMemberCoinArcsUseCase(
      ref.watch(memberCoinArcRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberCoinArcListControllerProvider =
    Provider.family<MemberCoinArcListController, dynamic>((ref, mid) {
      return MemberCoinArcListController(
        mid: mid,
        fetchCoinArcs: ref.watch(fetchMemberCoinArcsUseCaseProvider),
      );
    });
