import 'package:PiliPlus/models/coin_log/list.dart';

/// 经验日志项实体
///
/// 封装经验日志数据模型
class ExpLogItemEntity {
  /// 时间
  final String time;

  /// 变化量
  final String delta;

  /// 原因
  final String reason;

  const ExpLogItemEntity({
    required this.time,
    required this.delta,
    required this.reason,
  });

  /// 从模型创建实体
  factory ExpLogItemEntity.fromModel(CoinLogItem model) {
    return ExpLogItemEntity(
      time: model.time,
      delta: model.delta,
      reason: model.reason,
    );
  }

  /// 表头
  static const header = ExpLogItemEntity(
    time: '时间',
    delta: '变化',
    reason: '原因',
  );
}

/// 经验日志结果实体
class ExpLogResultEntity {
  /// 日志列表
  final List<ExpLogItemEntity>? items;

  const ExpLogResultEntity({
    this.items,
  });

  /// 从模型创建实体
  factory ExpLogResultEntity.fromModel(List<CoinLogItem>? items) {
    return ExpLogResultEntity(
      items: items?.map((e) => ExpLogItemEntity.fromModel(e)).toList(),
    );
  }
}
