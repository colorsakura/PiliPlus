import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/emote/package.dart';

/// 表情仓库接口
///
/// 定义表情相关数据操作的抽象
abstract interface class EmoteRepository {
  /// 获取表情包列表
  Future<LoadingState<List<Package>?>> getEmotePackages({
    required String business,
  });
}
