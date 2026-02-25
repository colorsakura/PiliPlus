import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub_detail/data.dart';
import 'package:PiliPlus/features/subscription_detail/domain/repositories/subscription_detail_repository.dart';
import 'package:PiliPlus/features/subscription_detail/data/datasources/subscription_detail_remote_datasource.dart';

/// Repository implementation for subscription detail data
class SubscriptionDetailRepositoryImpl implements SubscriptionDetailRepository {
  const SubscriptionDetailRepositoryImpl(this._datasource);

  final SubscriptionDetailRemoteDatasource _datasource;

  @override
  Future<LoadingState<SubDetailData>> getFavSeasonList({
    required int id,
    required int ps,
    required int pn,
  }) => _datasource.getFavSeasonList(
    id: id,
    ps: ps,
    pn: pn,
  );
}
