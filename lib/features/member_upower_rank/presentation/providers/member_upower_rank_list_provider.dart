import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_upower_rank/data/repositories/member_upower_rank_repository_impl.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/usecases/fetch_member_upower_rank.dart';
import 'package:PiliPlus/features/member_upower_rank/presentation/providers/member_upower_rank_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// Repository provider
final memberUpowerRankRepositoryProvider =
    Provider<MemberUpowerRankRepositoryImpl>((
  ref,
) {
  return MemberUpowerRankRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

/// Use case provider
final fetchMemberUpowerRankUseCaseProvider =
    Provider<FetchMemberUpowerRankUseCase>(
  (ref) {
    return FetchMemberUpowerRankUseCase(
      ref.watch(memberUpowerRankRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberUpowerRankListControllerProvider =
    Provider.family<MemberUpowerRankListController, String>((ref, upMid) {
      return MemberUpowerRankListController(
        upMid: upMid,
        fetchUpowerRank: ref.watch(fetchMemberUpowerRankUseCaseProvider),
      );
    });
