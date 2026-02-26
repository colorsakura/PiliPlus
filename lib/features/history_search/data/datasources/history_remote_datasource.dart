import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/history/data.dart';
import 'package:PiliPlus/utils/accounts/account.dart';

/// History remote data source interface
abstract class HistoryRemoteDataSource {
  /// Search history
  Future<LoadingState<HistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Account? account,
  });

  /// Delete history item(s)
  Future<LoadingState<void>> deleteHistory({
    required String historyKey,
    Account? account,
  });
}

/// History remote data source implementation
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  const HistoryRemoteDataSourceImpl();

  @override
  Future<LoadingState<HistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Account? account,
  }) {
    return UserHttp.searchHistory(
      pn: pn,
      keyword: keyword,
      account: account,
    );
  }

  @override
  Future<LoadingState<void>> deleteHistory({
    required String historyKey,
    Account? account,
  }) {
    return UserHttp.delHistory(
      historyKey,
      account: account,
    );
  }
}
