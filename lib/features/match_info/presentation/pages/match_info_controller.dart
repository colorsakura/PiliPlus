import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/match/match.dart';
import 'package:PiliPlus/models/match/match_info/contest.dart';
import 'package:PiliPlus/features/common/presentation/pages/dyn/common_dyn_controller.dart';
import 'package:get/get.dart';

class MatchInfoController extends CommonDynController {
  // Use Clean Architecture components
  final GetMatchInfo _getMatchInfo = GetMatchInfo(
    MatchRepositoryImpl(
      remoteDataSource: MatchRemoteDataSource(),
    ),
  );

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
    final result = await _getMatchInfo(cid: oid);

    // Handle LoadingState result
    if (result is Success<MatchContestEntity>) {
      // Convert entity back to model for compatibility with existing UI
      final entity = result.response;
      final contest = MatchContest(
        id: entity.id,
        gameStage: entity.gameStage,
        stime: entity.startTime,
        etime: entity.endTime,
        homeId: entity.homeId,
        awayId: entity.awayId,
        homeScore: entity.homeScore,
        awayScore: entity.awayScore,
        liveRoom: entity.liveRoom,
        aid: entity.aid,
        collection: entity.collection,
        collectionBvid: entity.collectionBvid,
        gameState: entity.gameState,
        dic: entity.dic,
        ctime: entity.createTime,
        mtime: entity.modifyTime,
        status: entity.status,
        sid: entity.seasonId,
        mid: entity.matchId,
        season: entity.season,
        homeTeam: entity.homeTeam,
        awayTeam: entity.awayTeam,
        special: entity.special,
        successTeam: entity.successTeam,
        successTeaminfo: entity.successTeaminfo,
        specialName: entity.specialName,
        specialTips: entity.specialTips,
        specialImage: entity.specialImage,
        playback: entity.playback,
        collectionUrl: entity.collectionUrl,
      );
      infoState.value = Success(contest);
      queryData();
    } else if (result is Error) {
      infoState.value = Error(result.errMsg ?? '获取赛事信息失败');
    }
  }
}
