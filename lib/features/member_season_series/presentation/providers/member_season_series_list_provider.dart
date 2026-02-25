import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_season_series/data/repositories/member_season_series_repository_impl.dart';
import 'package:PiliPlus/features/member_season_series/domain/usecases/fetch_member_season_series.dart';
import 'package:PiliPlus/features/member_season_series/presentation/providers/member_season_series_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

final memberSeasonSeriesRepositoryProvider =
    Provider<MemberSeasonSeriesRepositoryImpl>((
  ref,
) {
  return MemberSeasonSeriesRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

final fetchMemberSeasonSeriesUseCaseProvider =
    Provider<FetchMemberSeasonSeriesUseCase>(
  (ref) {
    return FetchMemberSeasonSeriesUseCase(
      ref.watch(memberSeasonSeriesRepositoryProvider),
    );
  },
);

final memberSeasonSeriesListControllerProvider =
    Provider.family<MemberSeasonSeriesListController, int>((ref, mid) {
      return MemberSeasonSeriesListController(
        mid: mid,
        fetchSeasonSeries: ref.watch(fetchMemberSeasonSeriesUseCaseProvider),
      );
    });
