import 'package:PiliPlus/http/black.dart' as http;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/blacklist/data.dart';

/// 黑名单远程数据源
///
/// 负责与黑名单API进行通信
class BlacklistRemoteDataSource {
  /// 获取黑名单列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<LoadingState<BlackListData>> fetchBlacklist({
    required int pn,
    required int ps,
  }) {
    return http.BlackHttp.blackList(
      pn: pn,
      ps: ps,
    );
  }
}
