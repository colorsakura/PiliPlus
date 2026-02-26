import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member/domain/entities/member_space_entity.dart';
import 'package:PiliPlus/features/member/domain/entities/member_entity.dart';
import 'package:PiliPlus/features/member/domain/entities/member_tab_entity.dart';
import 'package:PiliPlus/features/member/domain/repositories/member_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/common/member/tab_type.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/models/space/space/tab2.dart' as space_models show SpaceTab2;

/// 成员仓库实现
class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<MemberSpaceEntity> getMemberSpace({
    required int mid,
    String? fromViewAid,
  }) async {
    // 使用现有的HTTP请求方法
    final result = await MemberHttp.space(
      mid: mid,
      fromViewAid: fromViewAid,
    );

    if (result is Success<SpaceData>) {
      final data = result.response;
      final card = data.card;

      // 构建成员实体
      final member = MemberEntity.fromCard(card);

      // 构建标签页列表
      final tab2List = data.tab2 ?? [];
      final filteredTab2 = <space_models.SpaceTab2>[];
      for (final item in tab2List) {
        if (item.param != null && MemberTabType.contains(item.param!)) {
          filteredTab2.add(item);
        }
      }

      // 移除home标签（如果没有内容）
      if (data.hasItem != true && filteredTab2.isNotEmpty && filteredTab2.first.param == 'home') {
        filteredTab2.removeAt(0);
      }

      final tabs = filteredTab2
          .map((item) => MemberTabEntity.fromModel(item))
          .toList();

      // 检查是否有季度或系列
      final hasSeasonOrSeries =
          (data.ugcSeason?.count != null && data.ugcSeason?.count != 0) ||
          (data.series?.item?.isNotEmpty == true);

      // 计算关系状态
      final relation = data.relation == -1
          ? 128
          : card?.relation?.isFollow == 1
              ? card?.relation?.status ?? 2
              : 0;

      // 获取直播信息
      final live = data.live;

      return MemberSpaceEntity(
        member: member,
        tabs: tabs,
        hasSeasonOrSeries: hasSeasonOrSeries,
        live: live,
        relation: relation,
      );
    } else {
      throw Exception(
        result is Error ? result.errMsg : '获取成员空间信息失败',
      );
    }
  }

  @override
  Future<void> followMember({
    required int mid,
    required bool follow,
  }) async {
    // 这里应该调用关注/取消关注的API
    // 由于现有的代码可能分散在不同地方，这里先抛出UnimplementedError
    throw UnimplementedError('请使用现有的关注API');
  }

  @override
  Future<void> blockMember({
    required int mid,
    required bool block,
  }) async {
    // 这里应该调用拉黑/取消拉黑的API
    throw UnimplementedError('请使用现有的拉黑API');
  }

  @override
  Future<void> reportMember({
    required int mid,
    String? reason,
    int? reasonV2,
  }) async {
    await _remoteDataSource.reportMember(
      mid,
      reason: reason,
      reasonV2: reasonV2,
    );
  }
}
