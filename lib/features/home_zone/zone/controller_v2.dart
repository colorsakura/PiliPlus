import 'package:PiliPlus/core/controllers/common_controller_v2.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';

/// ZoneController V2 - Riverpod version
///
/// Handles ranking zone video lists
class ZoneControllerV2 extends CommonControllerV2<dynamic, dynamic> {
  ZoneControllerV2({this.rid, this.seasonType});

  final int? rid;
  final int? seasonType;

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading) return;
    isLoading = true;
    super.queryData(isRefresh);
  }

  @override
  Future<LoadingState<dynamic>> customGetData() async {
    if (rid != null) {
      final result = await VideoHttp.getRankVideoList(rid!);
      // Transform to LoadingState<List<dynamic?>>
      return result.when(
        loading: () => LoadingState<List<dynamic>?>.loading(),
        success: (data) {
          // data is List<HotVideoItemModel>
          return LoadingState<List<dynamic>?>.success(data as List<dynamic>?);
        },
        error: (errMsg) => LoadingState<List<dynamic>?>.error(errMsg),
      );
    }
    if (seasonType == 1) {
      final result = await VideoHttp.pgcRankList(seasonType: seasonType!);
      return result.when(
        loading: () => LoadingState<List<dynamic>?>.loading(),
        success: (data) => LoadingState<List<dynamic>?>.success(data as List<dynamic>?),
        error: (errMsg) => LoadingState<List<dynamic>?>.error(errMsg),
      );
    }
    final result = await VideoHttp.pgcSeasonRankList(seasonType: seasonType!);
    return result.when(
      loading: () => LoadingState<List<dynamic>?>.loading(),
      success: (data) => LoadingState<List<dynamic>?>.success(data as List<dynamic>?),
      error: (errMsg) => LoadingState<List<dynamic>?>.error(errMsg),
    );
  }
}
