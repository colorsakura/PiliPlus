import 'package:PiliPlus/models/match/match_info/contest.dart';
import 'package:PiliPlus/models/match/match_info/season.dart';
import 'package:PiliPlus/models/match/match_info/team.dart';
import 'package:PiliPlus/models/match/match_info/success_teaminfo.dart';

/// Match contest entity
class MatchContestEntity {
  final int? id;
  final String? gameStage;
  final int? startTime;
  final int? endTime;
  final int? homeId;
  final int? awayId;
  final int? homeScore;
  final int? awayScore;
  final int? liveRoom;
  final int? aid;
  final int? collection;
  final String? collectionBvid;
  final int? gameState;
  final String? dic;
  final String? createTime;
  final String? modifyTime;
  final int? status;
  final int? seasonId;
  final int? matchId;
  final Season? season;
  final MatchTeam? homeTeam;
  final MatchTeam? awayTeam;
  final int? special;
  final int? successTeam;
  final SuccessTeaminfo? successTeaminfo;
  final String? specialName;
  final String? specialTips;
  final String? specialImage;
  final String? playback;
  final String? collectionUrl;

  const MatchContestEntity({
    this.id,
    this.gameStage,
    this.startTime,
    this.endTime,
    this.homeId,
    this.awayId,
    this.homeScore,
    this.awayScore,
    this.liveRoom,
    this.aid,
    this.collection,
    this.collectionBvid,
    this.gameState,
    this.dic,
    this.createTime,
    this.modifyTime,
    this.status,
    this.seasonId,
    this.matchId,
    this.season,
    this.homeTeam,
    this.awayTeam,
    this.special,
    this.successTeam,
    this.successTeaminfo,
    this.specialName,
    this.specialTips,
    this.specialImage,
    this.playback,
    this.collectionUrl,
  });

  /// Create from MatchContest model
  factory MatchContestEntity.fromModel(MatchContest model) {
    return MatchContestEntity(
      id: model.id,
      gameStage: model.gameStage,
      startTime: model.stime,
      endTime: model.etime,
      homeId: model.homeId,
      awayId: model.awayId,
      homeScore: model.homeScore,
      awayScore: model.awayScore,
      liveRoom: model.liveRoom,
      aid: model.aid,
      collection: model.collection,
      collectionBvid: model.collectionBvid,
      gameState: model.gameState,
      dic: model.dic,
      createTime: model.ctime,
      modifyTime: model.mtime,
      status: model.status,
      seasonId: model.sid,
      matchId: model.mid,
      season: model.season,
      homeTeam: model.homeTeam,
      awayTeam: model.awayTeam,
      special: model.special,
      successTeam: model.successTeam,
      successTeaminfo: model.successTeaminfo,
      specialName: model.specialName,
      specialTips: model.specialTips,
      specialImage: model.specialImage,
      playback: model.playback,
      collectionUrl: model.collectionUrl,
    );
  }

  /// Check if match is live (gameState == 1)
  bool get isLive => gameState == 1;

  /// Check if match is upcoming (gameState == 0)
  bool get isUpcoming => gameState == 0;

  /// Check if match has ended (gameState == 2)
  bool get hasEnded => gameState == 2;

  /// Get match title
  String get title {
    if (season?.title != null) {
      return season!.title!;
    }
    if (specialName != null) {
      return specialName!;
    }
    return '比赛';
  }

  /// Get score text
  String get scoreText {
    if (homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return 'VS';
  }

  @override
  String toString() => 'MatchContestEntity(id: $id, title: $title, gameState: $gameState)';
}
