import 'package:PiliPlus/features/history/domain/entities/history_result.dart';

/// 历史记录仓库接口
///
/// 定义历史记录相关的数据操作抽象
abstract interface class HistoryRepository {
  /// 获取历史记录列表
  ///
  /// [type] 历史类型，null表示全部
  /// [max] 分页最大ID
  /// [viewAt] 分页查看时间
  Future<HistoryResultEntity> getHistoryList({
    String? type,
    int? max,
    int? viewAt,
  });

  /// 删除历史记录
  ///
  /// [keys] 要删除的记录标识符列表，格式为 "business_kid"
  Future<bool> deleteHistory(List<String> keys);

  /// 获取历史记录暂停状态
  ///
  /// 返回是否暂停记录历史
  Future<bool?> getHistoryStatus();
}
