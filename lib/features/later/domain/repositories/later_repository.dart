import 'package:PiliPlus/features/later/domain/entities/later_result.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';

/// 稍后再看仓库接口
abstract interface class LaterRepository {
  /// 获取稍后再看列表
  Future<LaterResultEntity> getLaterList({
    required int page,
    required LaterViewType viewType,
    String keyword,
    bool asc,
  });

  /// 删除稍后再看项
  Future<bool> removeLaterItem(String aids);

  /// 清空稍后再看
  Future<bool> clearLater([int? cleanType]);
}
