import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/data.dart';

/// Repository for subscription (sub folder) data
abstract class SubscriptionRepository {
  /// Fetch user subscription folders
  Future<LoadingState<SubData>> getUserSubFolders({
    required int pn,
    required int ps,
    required int mid,
  });

  /// Cancel a subscription
  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  });
}
