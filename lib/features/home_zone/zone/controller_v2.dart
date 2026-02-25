import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';

/// ZoneController V2 - Riverpod version
///
/// Handles ranking zone video lists
class ZoneControllerV2 extends CommonListControllerV2<dynamic, dynamic> {
  ZoneControllerV2({this.rid, this.seasonType});

  final int? rid;
  final int? seasonType;

  @override
  List? getDataList(dynamic response) {
    return response as List?;
  }

  @override
  Future<LoadingState> customGetData() async {
    if (rid != null) {
      return VideoHttp.getRankVideoList(rid!);
    }
    if (seasonType == 1) {
      return VideoHttp.pgcRankList(seasonType: seasonType!);
    }
    return VideoHttp.pgcSeasonRankList(seasonType: seasonType!);
  }
}
