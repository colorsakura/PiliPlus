import 'package:PiliPlus/models/coin_log/list.dart';

/// 硬币日志项实体
///
/// 封装硬币日志数据模型
class CoinLogItemEntity {
  /// 时间
  final String time;

  /// 变化量
  final String delta;

  /// 原因
  final String reason;

  const CoinLogItemEntity({
    required this.time,
    required this.delta,
    required this.reason,
  });

  /// 从模型创建实体
  factory CoinLogItemEntity.fromModel(CoinLogItem model) {
    return CoinLogItemEntity(
      time: model.time,
      delta: model.delta,
      reason: model.reason,
    );
  }

  /// 表头
  static const header = CoinLogItemEntity(
    time: '时间',
    delta: '变化',
    reason: '原因',
  );
}

/// 硬币日志结果实体
class CoinLogResultEntity {
  /// 日志列表
  final List<CoinLogItemEntity>? items;

  const CoinLogResultEntity({
    this.items,
  });

  /// 从模型创建实体
  factory CoinLogResultEntity.fromModel(List<CoinLogItem>? items) {
    return CoinLogResultEntity(
      items: items?.map((e) => CoinLogItemEntity.fromModel(e)).toList(),
    );
  }
}
