import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/later/data.dart';

/// 稍后再看远程数据源
class LaterRemoteDataSource {
  /// 获取稍后再看列表
  Future<LoadingState<LaterData>> fetchLaterList({
    required int page,
    required LaterViewType viewType,
    String keyword = '',
    bool asc = false,
  }) {
    return UserHttp.seeYouLater(
      page: page,
      viewed: viewType.type,
      keyword: keyword,
      asc: asc,
    );
  }

  /// 删除稍后再看项
  Future<LoadingState<void>> removeLaterItem(String aids) {
    return UserHttp.toViewDel(aids: aids);
  }

  /// 清空稍后再看
  Future<LoadingState<void>> clearLater([int? cleanType]) {
    return UserHttp.toViewClear(cleanType);
  }
}
