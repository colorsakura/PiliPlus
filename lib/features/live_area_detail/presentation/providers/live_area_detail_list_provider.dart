import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live_area_detail/data/repositories/live_area_detail_repository_impl.dart';
import 'package:PiliPlus/features/live_area_detail/domain/usecases/fetch_live_area_detail.dart';
import 'package:PiliPlus/features/live_area_detail/presentation/providers/live_area_detail_list_controller.dart';

final liveAreaDetailRepositoryProvider =
    Provider<LiveAreaDetailRepositoryImpl>((ref) {
  return const LiveAreaDetailRepositoryImpl();
});

final fetchLiveAreaDetailUseCaseProvider =
    Provider<FetchLiveAreaDetailUseCase>((ref) {
  return FetchLiveAreaDetailUseCase(
    ref.watch(liveAreaDetailRepositoryProvider),
  );
});

final liveAreaDetailListControllerProvider = Provider.family<
    LiveAreaDetailListController,
    ({dynamic areaId, dynamic parentAreaId})>((ref, params) {
  return LiveAreaDetailListController(
    areaId: params.areaId,
    parentAreaId: params.parentAreaId,
    fetchLiveAreaDetail: ref.watch(fetchLiveAreaDetailUseCaseProvider),
  );
});
