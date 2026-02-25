import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/blacklist/data/datasources/blacklist_http_datasource.dart'
    as http;
import 'package:PiliPlus/models/blacklist/data.dart';

/// 黑名单远程数据源
///
/// 负责与黑名单API进行通信
/// 现在使用新的 Clean Architecture 实现
class BlacklistRemoteDataSource {
  final http.BlacklistHttpDataSource _dataSource = http.BlacklistHttpDataSource();

  /// 获取黑名单列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<LoadingState<BlackListData>> fetchBlacklist({
    required int pn,
    required int ps,
  }) async {
    try {
      final result = await _dataSource.blackList(
        pn: pn,
        ps: ps,
      );
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
