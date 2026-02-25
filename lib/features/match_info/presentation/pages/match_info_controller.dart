import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/match/data/datasources/match_remote_datasource.dart';
import 'package:PiliPlus/models/match/match_info/contest.dart';
import 'package:PiliPlus/features/common/presentation/pages/dyn/common_dyn_controller.dart';
import 'package:get/get.dart';

class MatchInfoController extends CommonDynController {
  final MatchRemoteDataSource _dataSource = MatchRemoteDataSource();

  @override
  final int oid = int.parse(Get.parameters['cid']!);
  @override
  final int replyType = 27;

  @override
  dynamic get sourceId => oid.toString();

  final Rx<LoadingState<MatchContest?>> infoState =
      LoadingState<MatchContest?>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    getMatchInfo();
  }

  Future<void> getMatchInfo() async {
    try {
      final result = await _dataSource.matchInfo(oid);
      infoState.value = Success(result);
      queryData();
    } catch (e) {
      infoState.value = Error(e.toString());
    }
  }
}
