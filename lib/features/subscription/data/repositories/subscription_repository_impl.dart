import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/data.dart';
import 'package:PiliPlus/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:PiliPlus/features/subscription/data/datasources/subscription_remote_datasource.dart';

/// Repository implementation for subscription data
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._datasource);

  final SubscriptionRemoteDatasource _datasource;

  @override
  Future<LoadingState<SubData>> getUserSubFolders({
    required int pn,
    required int ps,
    required int mid,
  }) => _datasource.getUserSubFolders(
    pn: pn,
    ps: ps,
    mid: mid,
  );

  @override
  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  }) => _datasource.cancelSub(
    id: id,
    type: type,
  );
}
