import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart' as http;
import 'package:PiliPlus/models/history/data.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// 历史记录远程数据源
///
/// 负责与历史记录API进行通信
class HistoryRemoteDataSource {
  /// 获取历史记录列表
  ///
  /// [type] 历史类型
  /// [max] 分页最大ID
  /// [viewAt] 分页查看时间
  Future<LoadingState<HistoryData>> fetchHistoryList({
    String? type,
    int? max,
    int? viewAt,
  }) {
    return http.UserHttp.historyList(
      type: type ?? 'all',
      max: max,
      viewAt: viewAt,
      account: Accounts.main,
    );
  }

  /// 删除历史记录
  ///
  /// [keys] 要删除的记录标识符列表
  Future<LoadingState<dynamic>> deleteHistory(List<String> keys) {
    return http.UserHttp.delHistory(
      keys.join(','),
      account: Accounts.main,
    );
  }

  /// 获取历史记录暂停状态
  ///
  /// 返回是否暂停记录历史
  Future<LoadingState<dynamic>> getHistoryStatus() {
    return http.UserHttp.historyStatus(account: Accounts.main);
  }
}
